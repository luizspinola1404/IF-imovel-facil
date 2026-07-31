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
  const [mensagemSucesso, setMensagemSucesso] = useState("");

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
    setConfig({ ...config, cidades_alvo: novaLista });
    adicionarLog(`Cidade alvo adicionada: ${config.cidade} - ${config.estado}`);
  };

  const handleRemoverCidadeAlvo = (index: number) => {
    const lista = config.cidades_alvo || [];
    const novaLista = lista.filter((_, idx) => idx !== index);
    setConfig({ ...config, cidades_alvo: novaLista });
    adicionarLog(`Cidade removida da lista de alvos.`);
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

  const adicionarLog = (msg: string) => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs((prev) => [`[${timestamp}] ${msg}`, ...prev.slice(0, 49)]);
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
    adicionarLog(`Iniciando prospecção de imóveis em ${config.cidade}-${config.estado} na OLX...`);

    try {
      let resObj: SyncResult;

      if (typeof window !== "undefined" && ((window as any).__TAURI_INTERNALS__ || (window as any).__TAURI__)) {
        adicionarLog(`Executando motor nativo de raspagem em Rust...`);
        const { invoke } = await import("@tauri-apps/api/core");
        resObj = await invoke<SyncResult>("execute_prospeccao_now", { config });

        if (Array.isArray(resObj.logs)) {
          resObj.logs.forEach((stepLog) => adicionarLog(stepLog));
        }
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

      adicionarLog(`🎉 Finalizado! ${resObj.novos_encontrados} novos imóveis descobertos, ${resObj.removidos_encontrados} removidos da OLX.`);
    } catch (err: any) {
      adicionarLog(`❌ Erro de execução: ${err.message || err}`);
    } finally {
      setExecutando(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 font-sans p-6 space-y-6">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between border-b border-slate-800 pb-4 gap-4">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-purple-600 flex items-center justify-center font-bold text-white shadow-lg shadow-purple-500/20">
            IF
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-white">
              Agente Desktop de Prospecção
            </h1>
            <p className="text-xs text-slate-400">
              Software de Prospecção de Imóveis • Compatível com Windows, macOS & Linux
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleExecutarAgora}
            disabled={executando}
            className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-500 disabled:opacity-50 text-white text-xs font-bold px-4 py-2 rounded-lg transition-all shadow-md shadow-emerald-600/20"
          >
            {executando ? <RefreshCw className="h-4 w-4 animate-spin" /> : <Play className="h-4 w-4" />}
            <span>{executando ? "Prospectando..." : "Executar Agora"}</span>
          </button>
        </div>
      </div>

      {mensagemSucesso && (
        <div className="bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 px-4 py-3 rounded-lg text-xs flex items-center gap-2">
          <CheckCircle className="h-4 w-4" />
          <span>{mensagemSucesso}</span>
        </div>
      )}

      {/* Seção 1: Configuração do Servidor */}
      <div className="bg-slate-800/60 border border-slate-700/60 rounded-xl p-5 space-y-4">
        <div className="flex items-center gap-2 text-sm font-bold text-purple-400">
          <Server className="h-4 w-4" />
          <span>Servidor do Site</span>
        </div>

        <div className="space-y-1.5">
          <label className="text-xs text-slate-400">URL do Servidor do Site</label>
          <div className="relative">
            <Globe className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
            <input
              type="text"
              value={config.server_url}
              onChange={(e) => setConfig({ ...config, server_url: e.target.value })}
              placeholder="https://luizspinolaimoveis.com.br"
              className="w-full bg-slate-950 border border-slate-700 rounded-lg pl-9 pr-3 py-2 text-xs text-slate-100 placeholder:text-slate-500 focus:outline-none focus:border-purple-500 shadow-inner"
            />
          </div>
          <p className="text-[11px] text-slate-500">
            URL do servidor do site onde os imóveis capturados serão armazenados e exibidos.
          </p>
        </div>
      </div>

      {/* Seção 2: Localização & Agendamento de Polling */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Região e Imóveis */}
        <div className="bg-slate-800/60 border border-slate-700/60 rounded-xl p-5 space-y-4">
          <div className="flex items-center gap-2 text-sm font-bold text-blue-400">
            <Building className="h-4 w-4" />
            <span>Filtros de Prospecção</span>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1">
              <label className="text-xs text-slate-400 font-medium">Estado</label>
              <select
                value={config.estado}
                onChange={(e) => setConfig({ ...config, estado: e.target.value })}
                className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-purple-500 shadow-inner"
              >
                {ESTADOS.map((uf) => (
                  <option key={uf} value={uf} className="bg-slate-900 text-slate-100">
                    {uf}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-1">
              <label className="text-xs text-slate-400 font-medium flex items-center justify-between">
                <span>Cidade (IBGE)</span>
                {carregandoCidades && <span className="text-[10px] text-purple-400 animate-pulse">Buscando IBGE...</span>}
              </label>
              <div className="flex gap-2">
                <select
                  value={config.cidade}
                  onChange={(e) => setConfig({ ...config, cidade: e.target.value })}
                  disabled={carregandoCidades}
                  className="flex-1 bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-purple-500 shadow-inner disabled:opacity-60"
                >
                  {cidadesIBGE.length > 0 ? (
                    cidadesIBGE.map((c) => (
                      <option key={c.id} value={c.nome} className="bg-slate-900 text-slate-100">
                        {c.nome}
                      </option>
                    ))
                  ) : (
                    <option value={config.cidade} className="bg-slate-900 text-slate-100">
                      {config.cidade || "Carregando cidades..."}
                    </option>
                  )}
                </select>
                <button
                  type="button"
                  onClick={handleAdicionarCidadeAlvo}
                  className="bg-purple-600 hover:bg-purple-700 text-white text-xs font-medium px-3 py-2 rounded-lg flex items-center gap-1 shrink-0 transition-colors"
                  title="Adicionar à lista de varredura em lote"
                >
                  <Plus className="h-3.5 w-3.5" />
                  Add
                </button>
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-xs text-slate-400 font-medium">Tipo de Imóvel</label>
              <select
                value={config.tipo}
                onChange={(e) => setConfig({ ...config, tipo: e.target.value })}
                className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-purple-500 shadow-inner"
              >
                <option value="Casa" className="bg-slate-900 text-slate-100">Casa</option>
                <option value="Apartamento" className="bg-slate-900 text-slate-100">Apartamento</option>
                <option value="Terreno" className="bg-slate-900 text-slate-100">Terreno</option>
                <option value="Comercial" className="bg-slate-900 text-slate-100">Comercial</option>
              </select>
            </div>

            <div className="space-y-1">
              <label className="text-xs text-slate-400 font-medium">Modalidade</label>
              <select
                value={config.modalidade}
                onChange={(e) => setConfig({ ...config, modalidade: e.target.value })}
                className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-purple-500 shadow-inner"
              >
                <option value="venda" className="bg-slate-900 text-slate-100">Venda</option>
                <option value="aluguel" className="bg-slate-900 text-slate-100">Aluguel</option>
              </select>
            </div>
          </div>

          {/* Lista de Cidades Alvo Salvas */}
          <div className="pt-2 border-t border-slate-700/50 space-y-2">
            <div className="flex items-center justify-between text-xs text-slate-400 font-medium">
              <span>Cidades Alvo Salvas ({config.cidades_alvo?.length || 0}):</span>
              <span className="text-[10px] text-purple-400 font-normal">Sincronizado remotamente</span>
            </div>
            <div className="flex flex-wrap gap-1.5 max-h-24 overflow-y-auto pr-1">
              {config.cidades_alvo && config.cidades_alvo.length > 0 ? (
                config.cidades_alvo.map((alvo, idx) => (
                  <span
                    key={`${alvo.cidade}-${alvo.estado}-${idx}`}
                    className="inline-flex items-center gap-1.5 bg-slate-900 border border-slate-700/80 text-slate-200 text-xs px-2.5 py-1 rounded-full shadow-sm"
                  >
                    <span className="font-semibold text-blue-400">📍 {alvo.cidade} ({alvo.estado})</span>
                    <button
                      type="button"
                      onClick={() => handleRemoverCidadeAlvo(idx)}
                      className="text-slate-400 hover:text-red-400 transition-colors"
                      title="Remover cidade da lista"
                    >
                      <Trash2 className="h-3 w-3" />
                    </button>
                  </span>
                ))
              ) : (
                <span className="text-xs text-slate-500 italic">Nenhuma cidade salva na lista em lote.</span>
              )}
            </div>
          </div>
        </div>

        {/* Polling por Horários */}
        <div className="bg-slate-800/60 border border-slate-700/60 rounded-xl p-5 space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 text-sm font-bold text-amber-400">
              <Clock className="h-4 w-4" />
              <span>Horários do Polling Automático</span>
            </div>
            <label className="flex items-center gap-2 text-xs text-slate-300 cursor-pointer">
              <input
                type="checkbox"
                checked={config.auto_polling_enabled}
                onChange={(e) => setConfig({ ...config, auto_polling_enabled: e.target.checked })}
                className="rounded border-slate-700 text-purple-600 focus:ring-0"
              />
              <span>Ativo</span>
            </label>
          </div>

          <div className="flex gap-2">
            <input
              type="text"
              placeholder="Adicionar HH:MM (ex: 14:00)"
              value={novoHorario}
              onChange={(e) => setNovoHorario(e.target.value)}
              className="flex-1 bg-slate-950 border border-slate-700 rounded-lg px-3 py-1.5 text-xs text-slate-100 placeholder:text-slate-500 focus:outline-none focus:border-purple-500 shadow-inner"
            />
            <button
              onClick={handleAdicionarHorario}
              className="bg-slate-700 hover:bg-slate-600 text-white px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
            >
              <Plus className="h-3.5 w-3.5" /> Adicionar
            </button>
          </div>

          <div className="flex flex-wrap gap-2 pt-1">
            {config.polling_schedules.map((horario) => (
              <div
                key={horario}
                className="flex items-center gap-1.5 bg-slate-900 border border-slate-700 rounded-lg pl-3 pr-1.5 py-1 text-xs text-slate-200 font-mono"
              >
                <span>⏰ {horario}</span>
                <button
                  onClick={() => handleRemoverHorario(horario)}
                  className="text-slate-500 hover:text-red-400 p-0.5"
                >
                  <Trash2 className="h-3 w-3" />
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Salvar Botão */}
      <div className="flex justify-end">
        <button
          onClick={handleSalvarConfig}
          className="flex items-center gap-2 bg-purple-600 hover:bg-purple-500 text-white font-bold px-5 py-2.5 rounded-lg text-xs transition-all"
        >
          <Save className="h-4 w-4" /> Salvar Configurações
        </button>
      </div>

      {/* Seção 3: Histórico e Logs da Execução */}
      <div className="bg-slate-950 border border-slate-800 rounded-xl p-5 space-y-3">
        <div className="flex items-center justify-between text-xs text-slate-400">
          <span className="font-mono uppercase tracking-wider font-semibold">Console de Execução</span>
          <span>{logs.length} registros</span>
        </div>

        <div className="bg-slate-900/90 border border-slate-800 rounded-lg p-3 h-48 overflow-y-auto font-mono text-[11px] space-y-1 text-slate-300">
          {logs.length === 0 ? (
            <p className="text-slate-600 italic">Nenhuma execução registrada. Clique em "Executar Agora" para testar.</p>
          ) : (
            logs.map((log, idx) => <div key={idx}>{log}</div>)
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
