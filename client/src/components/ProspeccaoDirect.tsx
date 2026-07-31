import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import {
  ExternalLink,
  Loader2,
  Building,
  Filter,
  CheckCircle,
  Sparkles,
  AlertTriangle,
  RefreshCw,
  Trash2,
  Download,
  Target,
} from "lucide-react";

interface ScraperResult {
  id: string;
  titulo: string;
  link: string;
  fonte: string;
  trecho: string;
  direto_proprietario?: boolean;
  cidade: string;
  estado: string;
  tipo: string;
  modalidade: string;
  isNew?: boolean;
  status?: string; // 'active', 'removed', 'tentou_converter'
  firstSeenAt?: string;
  lastSeenAt?: string;
}

export function ProspeccaoDirect() {
  const { toast } = useToast();
  const [resultados, setResultados] = useState<ScraperResult[]>([]);
  const [carregando, setCarregando] = useState(false);
  const [marcandoId, setMarcandoId] = useState<string | null>(null);
  const [excluindoId, setExcluindoId] = useState<string | null>(null);
  const [filtroTexto, setFiltroTexto] = useState("");

  const carregarLeadsSincronizados = async () => {
    setCarregando(true);
    try {
      const res = await fetch("/api/prospeccao/leads");
      if (!res.ok) {
        throw new Error("Erro ao carregar imóveis prospectados");
      }

      const data: ScraperResult[] = await res.json();
      setResultados(data);
    } catch (err: any) {
      console.error(err);
      toast({
        title: "Erro ao carregar dados",
        description: err.message || "Não foi possível carregar os imóveis prospectados.",
        variant: "destructive",
      });
    } finally {
      setCarregando(false);
    }
  };

  useEffect(() => {
    carregarLeadsSincronizados();
  }, []);

  const handleExcluirLead = async (id: string) => {
    setExcluindoId(id);
    try {
      const res = await fetch(`/api/prospeccao/leads/${id}`, {
        method: "DELETE",
      });

      if (!res.ok) {
        throw new Error("Erro ao excluir imóvel prospectado");
      }

      setResultados((prev) => prev.filter((item) => item.id !== id));

      toast({
        title: "Imóvel Excluído",
        description: "O lead foi removido da lista.",
      });
    } catch (err: any) {
      toast({
        title: "Erro ao excluir",
        description: err.message || "Não foi possível excluir este imóvel.",
        variant: "destructive",
      });
    } finally {
      setExcluindoId(null);
    }
  };

  const handleLimparTodos = async () => {
    if (!window.confirm("Tem certeza que deseja excluir TODOS os imóveis prospectados da lista?")) {
      return;
    }

    setCarregando(true);
    try {
      const res = await fetch("/api/prospeccao/leads", {
        method: "DELETE",
      });

      if (!res.ok) {
        throw new Error("Erro ao limpar lista de prospecção");
      }

      setResultados([]);

      toast({
        title: "Lista Limpa!",
        description: "Todos os imóveis prospectados foram excluídos com sucesso.",
      });
    } catch (err: any) {
      toast({
        title: "Erro ao limpar lista",
        description: err.message || "Não foi possível excluir a lista.",
        variant: "destructive",
      });
    } finally {
      setCarregando(false);
    }
  };

  const handleMarcarConversao = async (id: string, statusAtual?: string) => {
    setMarcandoId(id);
    const novoStatus = statusAtual === "tentou_converter" ? "active" : "tentou_converter";
    try {
      const res = await fetch("/api/prospeccao/marcar-lead", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, status: novoStatus }),
      });

      if (!res.ok) {
        throw new Error("Erro ao atualizar status do lead");
      }

      setResultados((prev) =>
        prev.map((item) =>
          item.id === id ? { ...item, status: novoStatus } : item
        )
      );

      toast({
        title: novoStatus === "tentou_converter" ? "Lead Marcado! 🎯" : "Status Atualizado",
        description: novoStatus === "tentou_converter"
          ? "Lead marcado como em tentativa de conversão pelo corretor."
          : "Status do lead retornado para ativo.",
      });
    } catch (err: any) {
      console.error(err);
      toast({
        title: "Erro ao marcar lead",
        description: err.message || "Não foi possível atualizar o lead.",
        variant: "destructive",
      });
    } finally {
      setMarcandoId(null);
    }
  };

  const resultadosFiltrados = resultados.filter((r) => {
    if (!filtroTexto.trim()) return true;
    const query = filtroTexto.toLowerCase();
    return (
      r.titulo.toLowerCase().includes(query) ||
      r.trecho.toLowerCase().includes(query) ||
      r.cidade.toLowerCase().includes(query) ||
      r.estado.toLowerCase().includes(query) ||
      r.fonte.toLowerCase().includes(query)
    );
  });

  const leadsPorFonte = resultadosFiltrados.reduce((acc, lead) => {
    const fonteKey = lead.fonte || "OLX Brasil (Particular)";
    if (!acc[fonteKey]) acc[fonteKey] = [];
    acc[fonteKey].push(lead);
    return acc;
  }, {} as Record<string, ScraperResult[]>);

  const countNovos = resultados.filter((r) => r.isNew).length;
  const countRemovidos = resultados.filter((r) => r.status === "removed").length;
  const countAtivos = resultados.filter((r) => r.status === "active").length;
  const countTentando = resultados.filter((r) => r.status === "tentou_converter").length;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold">Imóveis Prospectados</h2>
          <p className="text-sm text-muted-foreground">
            Lista de imóveis de proprietários particulares agrupados por fonte para gestão de contatos e prospecção.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <a
            href="/api/desktop-agent/download"
            download="IF-Prospeccao-Agent-Windows.exe"
          >
            <Button
              variant="default"
              size="sm"
              className="gap-2 bg-blue-600 hover:bg-blue-700 text-white font-medium"
            >
              <Download className="h-4 w-4" />
              Baixar Agente Windows (.exe)
            </Button>
          </a>

          <Button
            onClick={handleLimparTodos}
            disabled={carregando}
            variant="destructive"
            size="sm"
            className="gap-2 font-medium bg-red-600 hover:bg-red-700 text-white"
            title="Excluir todos os imóveis da lista"
          >
            <Trash2 className="h-4 w-4" />
            Limpar Lista
          </Button>

          <Button
            onClick={carregarLeadsSincronizados}
            disabled={carregando}
            variant="outline"
            size="sm"
            className="gap-2"
          >
            <RefreshCw className={`h-4 w-4 ${carregando ? "animate-spin" : ""}`} />
            Atualizar Lista
          </Button>
        </div>
      </div>

      {carregando && (
        <div className="flex flex-col items-center justify-center py-12 gap-3 text-muted-foreground border rounded-lg bg-white">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
          <p className="text-sm font-medium">Carregando imóveis prospectados...</p>
        </div>
      )}

      {!carregando && resultados.length > 0 && (
        <div className="space-y-4">
          <div className="flex flex-wrap items-center justify-between gap-3 bg-white p-4 rounded-xl border shadow-sm">
            <div className="flex items-center gap-3 flex-wrap">
              <span className="text-sm font-bold text-slate-800">
                Total Capturado: {resultados.length} imóveis
              </span>
              <Badge className="bg-emerald-600 text-white border-0 text-xs px-2.5 py-1 flex items-center gap-1">
                <Sparkles className="h-3 w-3" />
                {countNovos} novos
              </Badge>
              <Badge variant="secondary" className="bg-blue-50 text-blue-700 border-blue-200 text-xs px-2.5 py-1">
                {countAtivos} ativos
              </Badge>
              {countTentando > 0 && (
                <Badge variant="secondary" className="bg-purple-50 text-purple-700 border-purple-200 text-xs px-2.5 py-1 flex items-center gap-1">
                  <Target className="h-3 w-3" />
                  {countTentando} em conversão
                </Badge>
              )}
              {countRemovidos > 0 && (
                <Badge variant="outline" className="text-red-600 border-red-200 bg-red-50 text-xs px-2.5 py-1 flex items-center gap-1">
                  <AlertTriangle className="h-3 w-3" />
                  {countRemovidos} removidos
                </Badge>
              )}
            </div>

            <div className="relative w-full sm:w-64">
              <Filter className="absolute left-2.5 top-2.5 h-3.5 w-3.5 text-muted-foreground" />
              <Input
                placeholder="Filtrar por texto..."
                value={filtroTexto}
                onChange={(e) => setFiltroTexto(e.target.value)}
                className="pl-8 h-8 text-xs bg-slate-50"
              />
            </div>
          </div>

          <Accordion
            type="multiple"
            defaultValue={Object.keys(leadsPorFonte)}
            className="space-y-4"
          >
            {Object.entries(leadsPorFonte).map(([fonteNome, leadsDaFonte]) => (
              <AccordionItem
                key={fonteNome}
                value={fonteNome}
                className="bg-white border rounded-xl shadow-sm px-4 overflow-hidden border-slate-200"
              >
                <AccordionTrigger className="hover:no-underline py-3.5">
                  <div className="flex items-center gap-3">
                    <span className="font-bold text-sm text-slate-800 flex items-center gap-2">
                      🟧 {fonteNome}
                    </span>
                    <Badge variant="secondary" className="bg-slate-100 text-slate-700 font-mono text-xs">
                      {leadsDaFonte.length} imóveis
                    </Badge>
                  </div>
                </AccordionTrigger>
                <AccordionContent className="pt-2 pb-4">
                  <div className="grid gap-3">
                    {leadsDaFonte.map((resultado, idx) => (
                      <div key={resultado.id} className="bg-slate-50/70 border rounded-lg p-4 hover:shadow-sm transition-shadow">
                        <div className="flex flex-wrap items-center justify-between gap-3">
                          <div className="flex items-center gap-2 flex-1 min-w-0">
                            <span className="text-xs font-bold text-slate-400 font-mono w-6">
                              #{idx + 1}
                            </span>

                            <Badge variant="outline" className="text-[10px] px-2 py-0.5 font-bold uppercase bg-white">
                              {resultado.cidade}-{resultado.estado}
                            </Badge>

                            {resultado.isNew && (
                              <Badge className="bg-emerald-600 hover:bg-emerald-700 text-white border-0 text-[10px] px-2 py-0.5 animate-pulse">
                                ⭐ NOVO
                              </Badge>
                            )}

                            {resultado.status === "tentou_converter" ? (
                              <Badge className="bg-purple-600 hover:bg-purple-700 text-white border-0 text-[10px] px-2 py-0.5 flex items-center gap-1">
                                🎯 TENTATIVA DE CONVERSÃO
                              </Badge>
                            ) : resultado.status === "removed" ? (
                              <Badge variant="destructive" className="text-[10px] px-2 py-0.5">
                                ❌ REMOVIDO DA OLX
                              </Badge>
                            ) : (
                              <Badge variant="secondary" className="text-[10px] px-2 py-0.5 bg-blue-50 text-blue-700 border-blue-200">
                                ATIVO
                              </Badge>
                            )}

                            <h4 className="font-semibold text-sm text-slate-800 truncate">
                              {resultado.titulo}
                            </h4>
                          </div>

                          <div className="flex items-center gap-2">
                            <a
                              href={resultado.link}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-xs text-primary inline-flex items-center gap-1 hover:underline font-medium bg-white px-2.5 py-1 rounded border"
                            >
                              Abrir Anúncio na OLX
                              <ExternalLink className="h-3 w-3" />
                            </a>

                            <Button
                              size="sm"
                              variant={resultado.status === "tentou_converter" ? "secondary" : "outline"}
                              disabled={marcandoId === resultado.id}
                              onClick={() => handleMarcarConversao(resultado.id, resultado.status)}
                              className={`h-7 text-xs gap-1 font-medium transition-colors ${
                                resultado.status === "tentou_converter"
                                  ? "bg-purple-100 text-purple-800 border-purple-300 hover:bg-purple-200"
                                  : "text-slate-700 hover:bg-slate-100 border-slate-300 bg-white"
                              }`}
                            >
                              {marcandoId === resultado.id ? (
                                <Loader2 className="h-3 w-3 animate-spin" />
                              ) : resultado.status === "tentou_converter" ? (
                                <>
                                  <Target className="h-3 w-3 text-purple-600" />
                                  <span>Tentou Converter 🎯</span>
                                </>
                              ) : (
                                <>
                                  <Target className="h-3 w-3 text-slate-500" />
                                  <span>Marcar Conversão</span>
                                </>
                              )}
                            </Button>

                            <Button
                              size="sm"
                              variant="ghost"
                              disabled={excluindoId === resultado.id}
                              onClick={() => handleExcluirLead(resultado.id)}
                              className="h-7 w-7 p-0 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg"
                              title="Excluir imóvel da lista"
                            >
                              {excluindoId === resultado.id ? (
                                <Loader2 className="h-3.5 w-3.5 animate-spin" />
                              ) : (
                                <Trash2 className="h-3.5 w-3.5" />
                              )}
                            </Button>
                          </div>
                        </div>
                        <p className="text-xs text-muted-foreground mt-2 pl-8 line-clamp-2">
                          {resultado.trecho}
                        </p>
                        <div className="flex items-center justify-between text-[11px] font-mono text-slate-400 mt-2 pl-8">
                          <span className="truncate max-w-md">{resultado.link}</span>
                          {resultado.lastSeenAt && (
                            <span className="shrink-0 text-slate-400">
                              Atualizado em: {new Date(resultado.lastSeenAt).toLocaleDateString("pt-BR")}
                            </span>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>
      )}

      {!carregando && resultados.length === 0 && (
        <div className="flex flex-col items-center justify-center py-16 gap-3 text-muted-foreground border rounded-lg bg-white">
          <Building className="h-12 w-12 opacity-20" />
          <p className="text-sm font-medium">
            Nenhum imóvel prospectado sincronizado no momento
          </p>
          <p className="text-xs text-center max-w-xs">
            Execute o Agente Desktop no seu computador para enviar imóveis capturados para este painel.
          </p>
        </div>
      )}
    </div>
  );
}
