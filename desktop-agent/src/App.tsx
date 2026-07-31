import { useState, useEffect } from "react";
import {
  Server,
  Clock,
  Play,
  Save,
  Plus,
  Trash2,
  Globe,
  CheckCircle,
  Building,
  RefreshCw,
} from "lucide-react";
import { listen } from "@tauri-apps/api/event";
import { invoke } from "@tauri-apps/api/core";

interface CidadeAlvo {
  estado: string;
  cidade: string;
}

interface AgentConfig {
  server_url: string;
  polling_schedules: string[];
  cidades_alvo?: CidadeAlvo[];
  estado: string;
  cidade: string;
  tipo: string;
  modalidade: string;
  auto_polling_enabled: boolean;
  headless: boolean;
}

const ESTADOS = [
  "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA",
  "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN",
  "RS", "RO", "RR", "SC", "SP", "SE", "TO"
];

export function App() {
  const [config, setConfig] = useState<AgentConfig>({
    server_url: "https://luizspinolaimoveis.com.br",
    polling_schedules: ["08:00", "12:00", "16:00", "20:00"],
    cidades_alvo: [],
    estado: "CE",
    cidade: "Juazeiro do Norte",
    tipo: "Casa",
    modalidade: "venda",
    auto_polling_enabled: true,
    headless: true,
  });

  const [cidadesIBGE, setCidadesIBGE] = useState<{ id: number; nome: string }[]>([]);
  const [carregandoCidades, setCarregandoCidades] = useState(false);
  const [novoHorario, setNovoHorario] = useState("");
  const [executando, setExecutando] = useState(false);
  const [logs, setLogs] = useState<string[]>([]);
  const [mensagemSucesso, setMensagemSucesso] = useState("");

  const sincronizarConfigComServidor = async (cfg: AgentConfig) => {
    try {
      await invoke("sync_server_config", { serverUrl: cfg.server_url, config: cfg });
      console.log("[TAURI] Configurações sincronizadas via Rust nativo com sucesso!");
      return;
    } catch (err) {
      console.error("[TAURI] Erro ou ambiente não-Tauri na sincronização nativa:", err);
    }

    try {
      const endpoint = `${cfg.server_url.replace(/\/$/, "")}/api/prospeccao/cidades-alvo`;
      await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          cidades: cfg.cidades_alvo || [],
          polling_schedules: cfg.polling_schedules || [],
          auto_polling_enabled: cfg.auto_polling_enabled ?? true,
        }),
      });
    } catch (e) {
      console.error("Erro ao sincronizar configuração com o servidor remoto:", e);
    }
  };

  const handleAdicionarCidadeAlvo = () => {
    if (!config.cidade) return;
    const jaExiste = config.cidades_alvo?.some(
      (item) => item.cidade.toLowerCase() === config.cidade.toLowerCase() && item.estado === config.estado
    );
    if (!jaExiste) {
      const novaLista = [...(config.cidades_alvo || []), { estado: config.estado, cidade: config.cidade }];
      const novaConfig = { ...config, cidades_alvo: novaLista };
      setConfig(novaConfig);
      sincronizarConfigComServidor(novaConfig);
      adicionarLog(`Cidade adicionada: ${config.cidade} (${config.estado})`);
    }
  };

  const handleRemoverCidadeAlvo = (index: number) => {
    const novaLista = [...(config.cidades_alvo || [])];
    const removida = novaLista.splice(index, 1)[0];
    const novaConfig = { ...config, cidades_alvo: novaLista };
    setConfig(novaConfig);
    sincronizarConfigComServidor(novaConfig);
    if (removida) {
      adicionarLog(`Cidade removida: ${removida.cidade} (${removida.estado})`);
    }
  };

  useEffect(() => {
    if (!config.estado) return;
    setCarregandoCidades(true);
    fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${config.estado}/municipios`)
      .then((res) => res.json())
      .then((data) => {
        const ordenadas = data.map((item: any) => ({ id: item.id, nome: item.nome })).sort((a: any, b: any) => a.nome.localeCompare(b.nome));
        setCidadesIBGE(ordenadas);
        if (ordenadas.length > 0 && !ordenadas.some((c: any) => c.nome === config.cidade)) {
          const primeira = ordenadas[0].nome;
          const novaConfig = { ...config, cidade: primeira };
          setConfig(novaConfig);
          sincronizarConfigComServidor(novaConfig);
        }
      })
      .catch((err) => console.error("Erro ao buscar cidades do IBGE:", err))
      .finally(() => setCarregandoCidades(false));
  }, [config.estado]);

  useEffect(() => {
    const carregarConfigInicial = async () => {
      try {
        const serverData = await invoke<any>("fetch_server_config", { serverUrl: config.server_url });
        console.log("[TAURI] Configurações carregadas do servidor nativo:", serverData);
        setConfig((prev) => ({
          ...prev,
          cidades_alvo: serverData.cidades || prev.cidades_alvo,
          polling_schedules: serverData.polling_schedules || prev.polling_schedules,
          auto_polling_enabled: serverData.auto_polling_enabled ?? prev.auto_polling_enabled,
        }));
        return;
      } catch (err) {
        console.log("[TAURI] Fallback de carregamento web:", err);
      }

      fetch(`${config.server_url.replace(/\/$/, "")}/api/prospeccao/cidades-alvo`)
        .then((res) => res.json())
        .then((data) => {
          if (data.cidades) {
            setConfig((prev) => ({
              ...prev,
              cidades_alvo: data.cidades || prev.cidades_alvo,
              polling_schedules: data.polling_schedules || prev.polling_schedules,
              auto_polling_enabled: data.auto_polling_enabled ?? prev.auto_polling_enabled,
            }));
          }
        })
        .catch((e) => console.error("[SERVIDOR] Erro ao carregar configurações:", e));
    };

    carregarConfigInicial();
  }, []);

  useEffect(() => {
    let unlisten: (() => void) | null = null;
    let isMounted = true;

    listen<string>("prospeccao_log", (event) => {
      console.log("[TAURI LOG RECEBIDO]:", event.payload);
      setLogs((prev) => [event.payload, ...prev.slice(0, 99)]);
      if (event.payload.includes("Varredura completa finalizada!")) {
        setExecutando(false);
      }
    })
      .then((fn) => {
        if (isMounted) {
          unlisten = fn;
        } else {
          fn();
        }
      })
      .catch((err) => {
        console.warn("Tauri event listener não disponível no navegador web:", err);
      });

    return () => {
      isMounted = false;
      if (unlisten) unlisten();
    };
  }, []);

  const adicionarLog = (msg: string) => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs((prev) => [`[${timestamp}] ${msg}`, ...prev.slice(0, 99)]);
  };

  const handleSalvarConfig = async () => {
    try {
      await invoke("save_config", { config });
    } catch (e) {
      console.log("Salvar config local web:", e);
    }
    await sincronizarConfigComServidor(config);
    setMensagemSucesso("Configurações salvas e sincronizadas com sucesso!");
    setTimeout(() => setMensagemSucesso(""), 4000);
  };

  const handleAdicionarHorario = () => {
    if (!novoHorario) return;
    if (!/^\d{2}:\d{2}$/.test(novoHorario)) {
      alert("Formato inválido. Use HH:MM ex: 14:30");
      return;
    }
    if (config.polling_schedules.includes(novoHorario)) return;
    const novosSchedules = [...config.polling_schedules, novoHorario].sort();
    const novaConfig = { ...config, polling_schedules: novosSchedules };
    setConfig(novaConfig);
    sincronizarConfigComServidor(novaConfig);
    setNovoHorario("");
    adicionarLog(`Novo horário agendado e atualizado no servidor: ${novoHorario}`);
  };

  const handleRemoverHorario = (horario: string) => {
    const novosSchedules = config.polling_schedules.filter((h) => h !== horario);
    const novaConfig = { ...config, polling_schedules: novosSchedules };
    setConfig(novaConfig);
    sincronizarConfigComServidor(novaConfig);
    adicionarLog(`Horário removido e atualizado no servidor: ${horario}`);
  };

  const handleExecutarAgora = async () => {
    setExecutando(true);
    adicionarLog("🚀 Iniciando varredura de prospecção no Agente Desktop...");

    try {
      await invoke("execute_prospeccao_now", { config });
    } catch (err: any) {
      try {
        const targetUrl = `${config.server_url.replace(/\/$/, "")}/api/prospeccao/sync`;
        adicionarLog(`Enviando dados capturados para a API ${targetUrl}...`);

        const res = await fetch(targetUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            batchId: `desktop-${Date.now()}`,
            fonte: "olx.com.br",
            estado: config.estado,
            cidade: config.cidade,
            tipo: config.tipo,
            modalidade: config.modalidade,
            items: [],
          }),
        });

        if (!res.ok) throw new Error(`Servidor respondeu HTTP ${res.status}`);
        adicionarLog(`🎉 Sincronização concluída com o servidor ${config.server_url}!`);
      } catch (webErr: any) {
        adicionarLog(`❌ Erro de execução: ${webErr.message || String(webErr)}`);
      } finally {
        setExecutando(false);
      }
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800 font-sans">
      <div className="bg-gradient-to-r from-blue-700 to-blue-500 shadow-md px-6 py-4 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="bg-white/10 p-2 rounded-lg backdrop-blur-sm">
            <Server className="h-6 w-6 text-white" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-white tracking-tight flex items-center gap-2">
              IF Prospecção Agent
              <span className="text-[10px] bg-blue-900/60 text-blue-200 border border-blue-400/30 px-2 py-0.5 rounded-full font-mono">v1.0.0</span>
            </h1>
            <p className="text-xs text-blue-100/90 font-medium">Agente Autônomo de Varredura e Captura de Imóveis</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleExecutarAgora}
            disabled={executando}
            className="flex items-center gap-2 bg-orange-500 hover:bg-orange-600 disabled:opacity-50 text-white text-sm font-bold px-5 py-2.5 rounded shadow-md transition-all uppercase tracking-wide"
          >
            {executando ? <RefreshCw className="h-4 w-4 animate-spin" /> : <Play className="h-4 w-4" />}
            <span>{executando ? "Prospectando..." : "Executar Agora"}</span>
          </button>
        </div>
      </div>

      <div className="p-6 space-y-6 max-w-7xl mx-auto">
        {mensagemSucesso && (
          <div className="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-md text-sm flex items-center gap-2 shadow-sm">
            <CheckCircle className="h-5 w-5 text-emerald-500" />
            <span className="font-medium">{mensagemSucesso}</span>
          </div>
        )}

        <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <div className="flex items-center gap-2 text-sm font-bold text-slate-700">
              <Globe className="h-4 w-4 text-blue-600" />
              <span className="uppercase tracking-wider">Conexão com o Servidor Central</span>
            </div>
            <button
              onClick={handleSalvarConfig}
              className="flex items-center gap-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-3 py-1.5 rounded-md shadow-sm transition-all"
            >
              <Save className="h-3.5 w-3.5" /> Salvar Configurações
            </button>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">URL do Servidor</label>
            <div className="relative">
              <Globe className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
              <input
                type="text"
                value={config.server_url}
                onChange={(e) => setConfig({ ...config, server_url: e.target.value })}
                placeholder="https://luizspinolaimoveis.com.br"
                className="w-full bg-slate-50 border border-slate-300 rounded-md pl-9 pr-3 py-2 text-sm text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-shadow"
              />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5 space-y-5 flex flex-col h-full">
            <div className="flex items-center gap-2 text-sm font-bold text-blue-700 border-b border-slate-100 pb-2.5">
              <Building className="h-4 w-4" />
              <span className="uppercase tracking-wider">Filtros de Prospecção</span>
            </div>

            <div className="flex flex-col sm:flex-row gap-4 items-start">
              <div className="space-y-1.5 w-full sm:w-1/3">
                <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide block">Estado</label>
                <select
                  value={config.estado}
                  onChange={(e) => setConfig({ ...config, estado: e.target.value })}
                  className="h-10 w-full bg-white border border-slate-300 rounded-lg px-3 text-sm text-slate-800 focus:outline-none focus:border-blue-600 focus:ring-1 focus:ring-blue-600 font-medium shadow-sm"
                >
                  {ESTADOS.map((uf) => (
                    <option key={uf} value={uf}>{uf}</option>
                  ))}
                </select>
              </div>

              <div className="space-y-1.5 w-full sm:w-2/3">
                <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide flex items-center justify-between">
                  <span>Cidade (IBGE)</span>
                  {carregandoCidades && <span className="text-[10px] text-blue-500 animate-pulse">Buscando...</span>}
                </label>
                <div className="flex gap-2">
                  <select
                    value={config.cidade}
                    onChange={(e) => setConfig((prev) => ({ ...prev, cidade: e.target.value }))}
                    disabled={carregandoCidades}
                    className="h-10 flex-1 bg-white border border-slate-300 rounded-lg px-3 text-sm text-slate-800 focus:outline-none focus:border-blue-600 focus:ring-1 focus:ring-blue-600 disabled:bg-slate-100 min-w-0 font-medium shadow-sm"
                  >
                    {cidadesIBGE.length > 0 ? (
                      cidadesIBGE.map((c) => (
                        <option key={c.id} value={c.nome}>{c.nome}</option>
                      ))
                    ) : (
                      <option value={config.cidade}>{config.cidade || "Carregando..."}</option>
                    )}
                  </select>
                  <button
                    type="button"
                    onClick={handleAdicionarCidadeAlvo}
                    className="h-10 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-4 rounded-lg flex items-center justify-center gap-1 shrink-0 transition-colors shadow-sm uppercase tracking-wide"
                  >
                    <Plus className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 space-y-2 mt-auto">
              <div className="flex items-center justify-between text-xs font-semibold text-slate-500 uppercase tracking-wide">
                <span>Cidades Alvo ({config.cidades_alvo?.length || 0})</span>
              </div>
              <div className="flex flex-wrap gap-2 max-h-24 overflow-y-auto pr-1">
                {config.cidades_alvo?.map((alvo, idx) => (
                    <span
                      key={`${alvo.cidade}-${alvo.estado}-${idx}`}
                      className="inline-flex items-center gap-1.5 bg-slate-50 border border-slate-200 text-slate-700 text-xs font-medium px-3 py-1 rounded-full shadow-sm"
                    >
                      <span className="text-blue-600">📍 {alvo.cidade} ({alvo.estado})</span>
                      <button
                        type="button"
                        onClick={() => handleRemoverCidadeAlvo(idx)}
                        className="text-slate-400 hover:text-red-500 transition-colors bg-white hover:bg-red-50 rounded-full p-0.5"
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </button>
                    </span>
                  ))}
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5 space-y-5 flex flex-col h-full">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2.5">
              <div className="flex items-center gap-2 text-sm font-bold text-orange-500">
                <Clock className="h-4 w-4" />
                <span className="uppercase tracking-wider">Agendamentos</span>
              </div>
              <div className="flex items-center gap-4">
                <label className="flex items-center gap-2 text-sm font-medium text-slate-600 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={config.headless}
                    onChange={(e) => {
                      const novaConfig = { ...config, headless: e.target.checked };
                      setConfig(novaConfig);
                      sincronizarConfigComServidor(novaConfig);
                    }}
                    className="w-4 h-4 rounded text-blue-600 focus:ring-blue-500 border-slate-300"
                  />
                  <span>Modo Invisível (Headless)</span>
                </label>
                <label className="flex items-center gap-2 text-sm font-medium text-slate-600 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={config.auto_polling_enabled}
                    onChange={(e) => {
                      const novaConfig = { ...config, auto_polling_enabled: e.target.checked };
                      setConfig(novaConfig);
                      sincronizarConfigComServidor(novaConfig);
                    }}
                    className="w-4 h-4 rounded text-blue-600 focus:ring-blue-500 border-slate-300"
                  />
                  <span>Auto-Polling Ativo</span>
                </label>
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide block">Adicionar Horário</label>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="HH:MM (ex: 14:00)"
                  value={novoHorario}
                  onChange={(e) => setNovoHorario(e.target.value)}
                  className="h-10 flex-1 bg-white border border-slate-300 rounded-lg px-3 text-sm text-slate-800 focus:outline-none focus:border-blue-600 focus:ring-1 focus:ring-blue-600 font-medium shadow-sm"
                />
                <button
                  onClick={handleAdicionarHorario}
                  className="h-10 bg-blue-50 hover:bg-blue-100 text-blue-700 border border-blue-200 px-4 rounded-lg text-xs font-bold uppercase tracking-wide flex items-center gap-1 shadow-sm transition-colors shrink-0"
                >
                  <Plus className="h-4 w-4" /> Adicionar
                </button>
              </div>
            </div>

            <div className="flex flex-wrap gap-2 pt-1 mt-auto">
              {config.polling_schedules.map((horario) => (
                <div
                  key={horario}
                  className="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-lg pl-3 pr-2 py-1.5 text-sm text-slate-700 font-medium shadow-sm"
                >
                  <span>⏰ {horario}</span>
                  <button
                    onClick={() => handleRemoverHorario(horario)}
                    className="text-slate-400 hover:text-red-500 p-1 rounded-md hover:bg-red-50 transition-colors"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="bg-slate-900 rounded-xl shadow-lg border border-slate-800 p-5 space-y-3">
          <div className="flex items-center justify-between text-xs text-slate-400 border-b border-slate-700 pb-2">
            <span className="font-mono uppercase tracking-widest font-bold text-blue-400">Terminal de Execução</span>
            <span className="font-medium bg-slate-800 px-2 py-0.5 rounded text-slate-300">{logs.length} registros</span>
          </div>

          <div className="h-64 overflow-y-auto font-mono text-[12px] space-y-1.5 text-slate-300 pt-2">
            {logs.length === 0 ? (
              <p className="text-slate-500 italic">Nenhuma execução registrada. Clique em "Executar Agora" para testar.</p>
            ) : (
              logs.map((log, idx) => (
                <div key={idx} className="border-b border-slate-800/50 pb-1 last:border-0">{log}</div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
