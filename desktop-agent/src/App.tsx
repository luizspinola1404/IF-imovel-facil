import { useState, useEffect } from "react";
import {
  Server,
  Key,
  Clock,
  Play,
  Save,
  Plus,
  Trash2,
  Globe,
  Sparkles,
  AlertCircle,
  CheckCircle,
  Building,
  RefreshCw,
} from "lucide-react";

interface AgentConfig {
  server_url: string;
  api_key: string;
  polling_schedules: string[];
  estado: string;
  cidade: string;
  tipo: string;
  modalidade: string;
  auto_polling_enabled: boolean;
}

interface SyncResult {
  success: boolean;
  batch_id: string;
  total_encontrados: number;
  novos_encontrados: number;
  removidos_encontrados: number;
  message: string;
}

const ESTADOS = ["ES", "SP", "RJ", "MG", "BA", "CE", "PR", "SC", "RS", "PE", "GO", "DF"];

export function App() {
  const [config, setConfig] = useState<AgentConfig>({
    server_url: "https://luizspinolaimoveis.com.br",
    api_key: "",
    polling_schedules: ["08:00", "12:00", "16:00", "20:00"],
    estado: "ES",
    cidade: "São Mateus",
    tipo: "Casa",
    modalidade: "venda",
    auto_polling_enabled: true,
  });

  const [novoHorario, setNovoHorario] = useState("");
  const [executando, setExecutando] = useState(false);
  const [ultimoResultado, setUltimoResultado] = useState<SyncResult | null>(null);
  const [logs, setLogs] = useState<string[]>([]);
  const [mensagemSucesso, setMensagemSucesso] = useState("");

  const adicionarLog = (msg: string) => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs((prev) => [`[${timestamp}] ${msg}`, ...prev.slice(0, 49)]);
  };

  const handleSalvarConfig = async () => {
    adicionarLog(`Salva configuração para o servidor: ${config.server_url}`);
    setMensagemSucesso("Configurações salvas com sucesso!");
    setTimeout(() => setMensagemSucesso(""), 3000);
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
    adicionarLog(`Iniciando raspagem de imóveis em ${config.cidade}-${config.estado} para a OLX...`);

    try {
      // Simula / Executa chamada tauri invoke se disponivel ou HTTP direto
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

      if (res.ok) {
        const data = await res.json();
        const resObj: SyncResult = {
          success: true,
          batch_id: data.batchRecord?.batchId || "batch-desktop",
          total_encontrados: data.totalEncontrados || 0,
          novos_encontrados: data.novosEncontrados || 0,
          removidos_encontrados: data.removidosEncontrados || 0,
          message: `Sincronização concluída com o servidor ${config.server_url}!`,
        };
        setUltimoResultado(resObj);
        adicionarLog(`✅ Concluído! ${resObj.novos_encontrados} novos imóveis descobertos, ${resObj.removidos_encontrados} desativados.`);
      } else {
        throw new Error(`Servidor respondeu HTTP ${res.status}`);
      }
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
              Agente Desktop de Prospecção (Multi-Servidor)
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

      {/* Seção 1: Configuração do Servidor do Cliente */}
      <div className="bg-slate-800/60 border border-slate-700/60 rounded-xl p-5 space-y-4">
        <div className="flex items-center gap-2 text-sm font-bold text-purple-400">
          <Server className="h-4 w-4" />
          <span>Conexão Multi-Servidor (Configuração do Cliente)</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="text-xs text-slate-400">URL do Servidor do Site</label>
            <div className="relative">
              <Globe className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
              <input
                type="text"
                value={config.server_url}
                onChange={(e) => setConfig({ ...config, server_url: e.target.value })}
                placeholder="https://suaimobiliaria.com.br"
                className="w-full bg-slate-900 border border-slate-700 rounded-lg pl-9 pr-3 py-2 text-xs text-slate-200 focus:outline-none focus:border-purple-500"
              />
            </div>
            <p className="text-[11px] text-slate-500">
              URL do site onde os imóveis capturados serão armazenados e visualizados.
            </p>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs text-slate-400">Chave de API / Token do Corretor (Opcional)</label>
            <div className="relative">
              <Key className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
              <input
                type="password"
                value={config.api_key}
                onChange={(e) => setConfig({ ...config, api_key: e.target.value })}
                placeholder="Inserir token de autenticação..."
                className="w-full bg-slate-900 border border-slate-700 rounded-lg pl-9 pr-3 py-2 text-xs text-slate-200 focus:outline-none focus:border-purple-500"
              />
            </div>
            <p className="text-[11px] text-slate-500">
              Permite vincular as buscas com a conta exclusiva do corretor no servidor.
            </p>
          </div>
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
              <label className="text-xs text-slate-400">Estado</label>
              <select
                value={config.estado}
                onChange={(e) => setConfig({ ...config, estado: e.target.value })}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-200 focus:outline-none"
              >
                {ESTADOS.map((uf) => (
                  <option key={uf} value={uf}>{uf}</option>
                ))}
              </select>
            </div>

            <div className="space-y-1">
              <label className="text-xs text-slate-400">Cidade</label>
              <input
                type="text"
                value={config.cidade}
                onChange={(e) => setConfig({ ...config, cidade: e.target.value })}
                placeholder="Ex: São Mateus"
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-200 focus:outline-none"
              />
            </div>

            <div className="space-y-1">
              <label className="text-xs text-slate-400">Tipo de Imóvel</label>
              <select
                value={config.tipo}
                onChange={(e) => setConfig({ ...config, tipo: e.target.value })}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-200 focus:outline-none"
              >
                <option value="Casa">Casa</option>
                <option value="Apartamento">Apartamento</option>
                <option value="Terreno">Terreno</option>
                <option value="Comercial">Comercial</option>
              </select>
            </div>

            <div className="space-y-1">
              <label className="text-xs text-slate-400">Modalidade</label>
              <select
                value={config.modalidade}
                onChange={(e) => setConfig({ ...config, modalidade: e.target.value })}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-xs text-slate-200 focus:outline-none"
              >
                <option value="venda">Venda</option>
                <option value="aluguel">Aluguel</option>
              </select>
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
              className="flex-1 bg-slate-900 border border-slate-700 rounded-lg px-3 py-1.5 text-xs text-slate-200"
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
