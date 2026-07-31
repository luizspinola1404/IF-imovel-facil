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
}

interface SyncResult {
  success: boolean;
  batch_id: string;
  target_url?: string;
  total_encontrados: number;
  novos_encontrados: number;
  removidos_encontrados: number;
  logs?: string[];
  message: string;
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
    cidades_alvo: [
      { estado: "CE", cidade: "Juazeiro do Norte" },
      { estado: "PE", cidade: "Petrolina" },
      { estado: "ES", cidade: "São Mateus" },
      { estado: "BA", cidade: "Salvador" },
    ],
    estado: "CE",
    cidade: "Juazeiro do Norte",
    tipo: "Casa",
    modalidade: "venda",
    auto_polling_enabled: true,
  });

  const [cidadesIBGE, setCidadesIBGE] = useState<{ id: number; nome: string }[]>([]);
  const [carregandoCidades, setCarregandoCidades] = useState(false);
  const [novoHorario, setNovoHorario] = useState("");
  const [executando, setExecutando] = useState(false);
  const [logs, setLogs] = useState<string[]>([]);
  const [progresso, setProgresso] = useState<{ atual: number; total: number } | null>(null);
  const [mensagemSucesso, setMensagemSucesso] = useState("");

  const sincronizarCidadesComServidor = async (novaLista: CidadeAlvo[]) => {
    try {
      const endpoint = `${config.server_url.replace(/\/$/, "")}/api/prospeccao/cidades-alvo`;
      await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ cidades: novaLista }),
      });
    } catch (e) {
      console.error("Erro ao sincronizar cidades com o servidor remoto:", e);
    }
  };

  const handleAdicionarCidadeAlvo = () => {
    if (!config.cidade || !config.estado) return;
    const lista = config.cidades_alvo || [];
    const existe = lista.some(
      (c) => c.cidade.toLowerCase() === config.cidade.toLowerCase() && c.estado === config.estado
    );
    if (existe) {
      alert(`A cidade ${config.cidade}-${config.estado} já está na lista!`);
      return;
    }

    const novaLista = [...lista, { estado: config.estado, cidade: config.cidade }];
    const novaConfig = { ...config, cidades_alvo: novaLista };
    setConfig(novaConfig);
    if (typeof window !== "undefined" && ((window as any).__TAURI_INTERNALS__ || (window as any).__TAURI__)) {
      import("@tauri-apps/api/core").then(({ invoke }) => invoke("save_config", { config: novaConfig }));
    }
    sincronizarCidadesComServidor(novaLista);
    adicionarLog(`Cidade alvo adicionada e salva no servidor: ${config.cidade} - ${config.estado}`);
  };

  const handleRemoverCidadeAlvo = (index: number) => {
    const lista = config.cidades_alvo || [];
    const cidadeRemovida = lista[index];
    const novaLista = lista.filter((_, idx) => idx !== index);
    const novaConfig = { ...config, cidades_alvo: novaLista };
    setConfig(novaConfig);
    if (typeof window !== "undefined" && ((window as any).__TAURI_INTERNALS__ || (window as any).__TAURI__)) {
      import("@tauri-apps/api/core").then(({ invoke }) => invoke("save_config", { config: novaConfig }));
    }
    sincronizarCidadesComServidor(novaLista);
    adicionarLog(`Cidade ${cidadeRemovida?.cidade} removida. Imóveis desta cidade foram apagados do servidor remoto.`);
  };

  useEffect(() => {
    if (!config.estado) return;
    setCarregandoCidades(true);
    fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${config.estado}/municipios?orderBy=nome`)
      .then((res) => res.json())
      .then((data) => {
        if (Array.isArray(data)) {
          const lista = data.map((c: any) => ({ id: c.id, nome: c.nome }));
          setCidadesIBGE(lista);
          // Se a cidade atual não pertence ao novo estado, seleciona a primeira do IBGE
          if (lista.length > 0 && !lista.some((c) => c.nome.toLowerCase() === config.cidade.toLowerCase())) {
            setConfig((prev) => ({ ...prev, cidade: lista[0].nome }));
          }
        }
      })
      .catch((err) => console.error("Erro ao buscar cidades no IBGE:", err))
      .finally(() => setCarregandoCidades(false));
  }, [config.estado]);

  // Carregar cidades salvas no Servidor ao iniciar o App
  useEffect(() => {
    const endpoint = `${config.server_url.replace(/\/$/, "")}/api/prospeccao/cidades-alvo`;
    fetch(endpoint)
      .then((res) => res.json())
      .then((data) => {
        if (data && Array.isArray(data.cidades) && data.cidades.length > 0) {
          console.log("Cidades salvas no servidor:", data.cidades);
          setConfig((prev) => ({ ...prev, cidades_alvo: data.cidades }));
        }
      })
      .catch((e) => console.error("Erro ao carregar cidades alvo do servidor:", e));
  }, []);

  useEffect(() => {
    let unlistenFn: (() => void) | null = null;
    let isMounted = true;

    const setupListener = async () => {
      if (typeof window !== "undefined" && ((window as any).__TAURI_INTERNALS__ || (window as any).__TAURI__)) {
        try {
          const { listen } = await import("@tauri-apps/api/event");
          const unlisten = await listen<string>("prospeccao_log", (event) => {
            console.log("Recebido do Rust:", event.payload);
            setLogs((prev) => [event.payload, ...prev.slice(0, 99)]);
            
            // Detectar progresso ex: [1/16]
            const match = event.payload.match(/\[(\d+)\/(\d+)\]/);
            if (match) {
              setProgresso({ atual: parseInt(match[1]), total: parseInt(match[2]) });
            }
            if (event.payload.includes("Varredura completa finalizada!")) {
              setProgresso(null);
            }
          });
          if (isMounted) {
            unlistenFn = unlisten;
          } else {
            unlisten();
          }
        } catch (e) {
          console.error("Erro ao registrar listener do Tauri:", e);
        }
      }
    };

    setupListener();

    return () => {
      isMounted = false;
      if (unlistenFn) unlistenFn();
    };
  }, []);

  const adicionarLog = (msg: string) => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs((prev) => [`[${timestamp}] ${msg}`, ...prev.slice(0, 99)]);
  };

  const handleSalvarConfig = async () => {
    try {
      if (typeof window !== "undefined" && ((window as any).__TAURI_INTERNALS__ || (window as any).__TAURI__)) {
        const { invoke } = await import("@tauri-apps/api/core");
        await invoke("save_config", { config });
      }

      const remoteEndpoint = `${config.server_url.replace(/\/$/, "")}/api/prospeccao/cidades-alvo`;
      fetch(remoteEndpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ cidades: config.cidades_alvo || [] }),
      }).catch((e) => console.error("Erro ao salvar cidades remotamente:", e));

      adicionarLog(`Salva configurações e ${config.cidades_alvo?.length || 0} cidades alvo no servidor: ${config.server_url}`);
      setMensagemSucesso("Configurações e cidades alvo salvas remotamente!");
      setTimeout(() => setMensagemSucesso(""), 3000);
    } catch (err: any) {
      adicionarLog(`Erro ao salvar configurações: ${err}`);
    }
  };

  const handleAdicionarHorario = () => {
    if (!novoHorario || !/^\d{2}:\d{2}$/.test(novoHorario)) {
      alert("Por favor digite um horário válido no formato HH:MM (ex: 14:30)");
      return;
    }
    if (config.polling_schedules.includes(novoHorario)) {
      return;
    }
    setConfig({
      ...config,
      polling_schedules: [...config.polling_schedules, novoHorario].sort(),
    });
    setNovoHorario("");
    adicionarLog(`Novo horário de polling adicionado: ${novoHorario}`);
  };

  const handleRemoverHorario = (horario: string) => {
    setConfig({
      ...config,
      polling_schedules: config.polling_schedules.filter((h) => h !== horario),
    });
    adicionarLog(`Horário removido: ${horario}`);
  };

  const handleExecutarAgora = async () => {
    setExecutando(true);
    const totalCombos = (config.cidades_alvo?.length || 1) * 4 * 2;
    setProgresso({ atual: 0, total: totalCombos });
    adicionarLog("🚀 Iniciando varredura de prospecção no Agente Desktop...");

    try {
      let resObj: SyncResult;

      if (typeof window !== "undefined" && ((window as any).__TAURI_INTERNALS__ || (window as any).__TAURI__)) {
        const { invoke } = await import("@tauri-apps/api/core");
        resObj = await invoke<SyncResult>("execute_prospeccao_now", { config });
      } else {
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
        const data = await res.json();
        resObj = {
          success: true,
          batch_id: data.batchRecord?.batchId || "batch-desktop",
          target_url: targetUrl,
          total_encontrados: data.totalEncontrados || 0,
          novos_encontrados: data.novosEncontrados || 0,
          removidos_encontrados: data.removidosEncontrados || 0,
          logs: [],
          message: `Sincronização concluída com o servidor ${config.server_url}!`,
        };
      }

      if (resObj.logs && resObj.logs.length > 0) {
        setLogs(resObj.logs.slice().reverse());
      }
      adicionarLog(`🎉 Finalizado! ${resObj.novos_encontrados} novos imóveis descobertos, ${resObj.removidos_encontrados} removidos da OLX.`);
    } catch (err: any) {
      adicionarLog(`❌ Erro de execução: ${typeof err === 'object' ? JSON.stringify(err) : String(err)}`);
    } finally {
      setExecutando(false);
      setProgresso(null);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800 font-sans">
      {/* Header (App Bar like Material UI) */}
      <div className="bg-gradient-to-r from-blue-700 to-blue-500 shadow-md px-6 py-4 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <img src="/logo.png" alt="IF Imóvel Fácil" className="h-12 w-12 rounded-lg object-contain bg-white shadow-sm p-1" />
          <div>
            <h1 className="text-xl font-bold tracking-tight text-white">
              Agente Desktop de Prospecção
            </h1>
            <p className="text-xs text-blue-100 font-medium">
              Compatível com Windows, macOS & Linux
            </p>
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

        {/* Seção 1: Configuração do Servidor */}
        <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5 space-y-4">
          <div className="flex items-center gap-2 text-sm font-bold text-blue-700 border-b border-slate-100 pb-2">
            <Server className="h-4 w-4" />
            <span className="uppercase tracking-wider">Servidor do Site</span>
          </div>

          <div className="space-y-1.5">
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
            <p className="text-[11px] text-slate-500 font-medium">
              Onde os imóveis capturados serão armazenados e exibidos.
            </p>
          </div>
        </div>

        {/* Seção 2: Localização & Agendamento de Polling */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Região e Imóveis */}
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
                    onChange={(e) => setConfig({ ...config, cidade: e.target.value })}
                    disabled={carregandoCidades}
                    className="h-10 flex-1 bg-white border border-slate-300 rounded-lg px-3 text-sm text-slate-800 focus:outline-none focus:border-blue-600 focus:ring-1 focus:ring-blue-600 disabled:bg-slate-100 min-w-0 font-medium shadow-sm"
                  >
                    {cidadesIBGE.length > 0 ? (
                      cidadesIBGE.map((c) => (
                        <option key={c.id} value={c.nome}>{c.nome}</option>
                      ))
                    ) : (
                      <option value={config.cidade}>{config.cidade || "Carregando cidades..."}</option>
                    )}
                  </select>
                  <button
                    type="button"
                    onClick={handleAdicionarCidadeAlvo}
                    className="h-10 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-4 rounded-lg flex items-center justify-center gap-1 shrink-0 transition-colors shadow-sm uppercase tracking-wide"
                    title="Adicionar à lista"
                  >
                    <Plus className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>

            {/* Lista de Cidades Alvo Salvas */}
            <div className="pt-3 border-t border-slate-100 space-y-2 mt-auto">
              <div className="flex items-center justify-between text-xs font-semibold text-slate-500 uppercase tracking-wide">
                <span>Cidades Alvo ({config.cidades_alvo?.length || 0})</span>
                <span className="text-[10px] text-blue-500 font-bold bg-blue-50 px-2 py-0.5 rounded-full">Sincronizado</span>
              </div>
              <div className="flex flex-wrap gap-2 max-h-24 overflow-y-auto pr-1">
                {config.cidades_alvo && config.cidades_alvo.length > 0 ? (
                  config.cidades_alvo.map((alvo, idx) => (
                    <span
                      key={`${alvo.cidade}-${alvo.estado}-${idx}`}
                      className="inline-flex items-center gap-1.5 bg-slate-50 border border-slate-200 text-slate-700 text-xs font-medium px-3 py-1 rounded-full shadow-sm"
                    >
                      <span className="text-blue-600">📍 {alvo.cidade} ({alvo.estado})</span>
                      <button
                        type="button"
                        onClick={() => handleRemoverCidadeAlvo(idx)}
                        className="text-slate-400 hover:text-red-500 transition-colors bg-white hover:bg-red-50 rounded-full p-0.5"
                        title="Remover"
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </button>
                    </span>
                  ))
                ) : (
                  <span className="text-sm text-slate-500">Nenhuma cidade salva.</span>
                )}
              </div>
            </div>
          </div>

          {/* Polling por Horários */}
          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5 space-y-5 flex flex-col h-full">
            <div className="flex items-center justify-between border-b border-slate-100 pb-2.5">
              <div className="flex items-center gap-2 text-sm font-bold text-orange-500">
                <Clock className="h-4 w-4" />
                <span className="uppercase tracking-wider">Agendamentos</span>
              </div>
              <label className="flex items-center gap-2 text-sm font-medium text-slate-600 cursor-pointer">
                <input
                  type="checkbox"
                  checked={config.auto_polling_enabled}
                  onChange={(e) => setConfig({ ...config, auto_polling_enabled: e.target.checked })}
                  className="w-4 h-4 rounded text-blue-600 focus:ring-blue-500 border-slate-300"
                />
                <span>Ativo</span>
              </label>
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

        {/* Salvar Botão */}
        <div className="flex justify-end pt-2">
          <button
            onClick={handleSalvarConfig}
            className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-bold px-6 py-3 rounded shadow-md text-sm transition-all uppercase tracking-wide"
          >
            <Save className="h-4 w-4" /> Salvar Configurações
          </button>
        </div>

        {/* Seção 3: Histórico e Logs da Execução */}
        <div className="bg-slate-900 rounded-xl shadow-lg border border-slate-800 p-5 space-y-3">
          <div className="flex items-center justify-between text-xs text-slate-400 border-b border-slate-700 pb-2">
            <span className="font-mono uppercase tracking-widest font-bold text-blue-400">Terminal de Execução</span>
            <span className="font-medium bg-slate-800 px-2 py-0.5 rounded text-slate-300">{logs.length} registros</span>
          </div>

          {progresso && (
            <div className="pt-2 pb-1">
              <div className="flex justify-between text-xs text-blue-300 font-medium mb-1">
                <span>Progresso da Varredura</span>
                <span>{progresso.atual} de {progresso.total} ({Math.round((progresso.atual / progresso.total) * 100)}%)</span>
              </div>
              <div className="w-full bg-slate-800 rounded-full h-2.5">
                <div 
                  className="bg-blue-500 h-2.5 rounded-full transition-all duration-500 ease-out" 
                  style={{ width: `${(progresso.atual / progresso.total) * 100}%` }}
                ></div>
              </div>
            </div>
          )}

          <div className="h-48 overflow-y-auto font-mono text-[12px] space-y-1.5 text-slate-300 pt-2">
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
