import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import {
  ExternalLink,
  Loader2,
  Building,
  PlusCircle,
  Filter,
  CheckCircle,
  Sparkles,
  AlertTriangle,
  RefreshCw,
  Search,
} from "lucide-react";

const ESTADOS_BR = [
  "AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG",
  "PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO",
];

const TIPOS = ["Casa", "Apartamento", "Terreno", "Comercial"];

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
  status?: string; // 'active', 'removed', 'saved'
  firstSeenAt?: string;
  lastSeenAt?: string;
}

export function ProspeccaoDirect() {
  const { toast } = useToast();
  const [estado, setEstado] = useState("todos");
  const [cidade, setCidade] = useState("todas");
  const [tipo, setTipo] = useState("todos");
  const [modalidade, setModalidade] = useState("todas");
  const [statusFiltro, setStatusFiltro] = useState("todos");

  const [resultados, setResultados] = useState<ScraperResult[]>([]);
  const [carregando, setCarregando] = useState(false);
  const [salvandoId, setSalvandoId] = useState<string | null>(null);
  const [leadsSalvosIds, setLeadsSalvosIds] = useState<Set<string>>(new Set());
  const [filtroTexto, setFiltroTexto] = useState("");

  // Dynamic cities states
  const [cidades, setCidades] = useState<{ id: number; nome: string }[]>([]);
  const [loadingCidades, setLoadingCidades] = useState(false);

  // Fetch cities when estado changes
  useEffect(() => {
    if (!estado || estado === "todos") {
      setCidades([]);
      setCidade("todas");
      return;
    }

    const fetchCidades = async () => {
      setLoadingCidades(true);
      try {
        const res = await fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${estado}/municipios`);
        if (!res.ok) throw new Error("Erro ao carregar cidades");
        const data = await res.json();
        const sorted = data.sort((a: any, b: any) => {
          const nameA = a?.nome ?? "";
          const nameB = b?.nome ?? "";
          return nameA.localeCompare(nameB);
        });
        setCidades(sorted);
      } catch (err) {
        console.error(err);
        setCidades([]);
      } finally {
        setLoadingCidades(false);
      }
    };

    fetchCidades();
  }, [estado]);

  const carregarLeadsSincronizados = async () => {
    setCarregando(true);
    try {
      let queryParams = [];
      if (estado && estado !== "todos") queryParams.push(`estado=${encodeURIComponent(estado)}`);
      if (cidade && cidade !== "todas") queryParams.push(`cidade=${encodeURIComponent(cidade)}`);
      if (tipo && tipo !== "todos") queryParams.push(`tipo=${encodeURIComponent(tipo)}`);
      if (modalidade && modalidade !== "todas") queryParams.push(`modalidade=${encodeURIComponent(modalidade)}`);
      if (statusFiltro && statusFiltro !== "todos") queryParams.push(`status=${encodeURIComponent(statusFiltro)}`);

      const queryString = queryParams.length > 0 ? `?${queryParams.join("&")}` : "";
      const res = await fetch(`/api/prospeccao/leads${queryString}`);
      if (!res.ok) {
        throw new Error("Erro ao carregar leads sincronizados");
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

  // Executa o carregamento automático na montagem inicial e ao alterar filtros
  useEffect(() => {
    carregarLeadsSincronizados();
  }, [estado, cidade, tipo, modalidade, statusFiltro]);

  const handleSalvarLead = async (resultado: ScraperResult) => {
    setSalvandoId(resultado.id);
    try {
      const res = await fetch("/api/prospeccao/salvar-lead", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(resultado),
      });

      if (!res.ok) {
        throw new Error("Erro ao registrar lead no banco");
      }

      setLeadsSalvosIds((prev) => new Set(prev).add(resultado.id));

      toast({
        title: "Lead Salvo!",
        description: `"${resultado.titulo}" foi cadastrado no sistema.`,
      });
    } catch (err: any) {
      console.error(err);
      toast({
        title: "Erro ao salvar lead",
        description: err.message || "Não foi possível salvar este lead.",
        variant: "destructive",
      });
    } finally {
      setSalvandoId(null);
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

  const countNovos = resultados.filter((r) => r.isNew).length;
  const countRemovidos = resultados.filter((r) => r.status === "removed").length;
  const countAtivos = resultados.filter((r) => r.status === "active").length;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold">Imóveis Prospectados (Sincronização Desktop)</h2>
          <p className="text-sm text-muted-foreground">
            Todos os imóveis de proprietários particulares capturados e atualizados via Agente Desktop.
          </p>
        </div>

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

      <div className="grid grid-cols-1 md:grid-cols-5 gap-4 bg-slate-50 p-4 rounded-lg border">
        <div className="space-y-2">
          <Label htmlFor="estado">Estado</Label>
          <Select value={estado} onValueChange={setEstado}>
            <SelectTrigger id="estado">
              <SelectValue placeholder="Todos os Estados" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="todos">Todos os Estados</SelectItem>
              {ESTADOS_BR.map((uf) => (
                <SelectItem key={uf} value={uf}>{uf}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2">
          <Label htmlFor="cidade">Cidade</Label>
          {loadingCidades ? (
            <div className="flex items-center h-10 border rounded-md px-3 bg-white text-xs text-muted-foreground">
              <Loader2 className="h-3.5 w-3.5 animate-spin mr-2" />
              Buscando cidades...
            </div>
          ) : cidades.length > 0 ? (
            <Select value={cidade} onValueChange={setCidade}>
              <SelectTrigger id="cidade">
                <SelectValue placeholder="Todas as Cidades" />
              </SelectTrigger>
              <SelectContent className="max-h-[300px] overflow-y-auto">
                <SelectItem value="todas">Todas as Cidades</SelectItem>
                {cidades.map((c) => (
                  <SelectItem key={c.id} value={c.nome}>
                    {c.nome}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          ) : (
            <Input
              id="cidade"
              placeholder="Todas as cidades"
              value={cidade === "todas" ? "" : cidade}
              onChange={(e) => setCidade(e.target.value || "todas")}
            />
          )}
        </div>

        <div className="space-y-2">
          <Label htmlFor="tipo">Tipo de Imóvel</Label>
          <Select value={tipo} onValueChange={setTipo}>
            <SelectTrigger id="tipo">
              <SelectValue placeholder="Tipo" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="todos">Todos os Tipos</SelectItem>
              {TIPOS.map((t) => (
                <SelectItem key={t} value={t}>{t}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2">
          <Label htmlFor="modalidade">Modalidade</Label>
          <Select value={modalidade} onValueChange={setModalidade}>
            <SelectTrigger id="modalidade">
              <SelectValue placeholder="Todas" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="todas">Todas as Modalidades</SelectItem>
              <SelectItem value="venda">Venda</SelectItem>
              <SelectItem value="aluguel">Aluguel</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2">
          <Label htmlFor="statusFiltro">Status na Plataforma</Label>
          <Select value={statusFiltro} onValueChange={setStatusFiltro}>
            <SelectTrigger id="statusFiltro">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="todos">Todos os Status</SelectItem>
              <SelectItem value="active">Imóveis Ativos</SelectItem>
              <SelectItem value="removed">Removidos da OLX</SelectItem>
            </SelectContent>
          </Select>
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
                placeholder="Filtrar imóveis..."
                value={filtroTexto}
                onChange={(e) => setFiltroTexto(e.target.value)}
                className="pl-8 h-8 text-xs bg-slate-50"
              />
            </div>
          </div>

          <div className="grid gap-3">
            {resultadosFiltrados.map((resultado, idx) => (
              <div key={resultado.id} className="bg-white border rounded-lg p-4 hover:shadow-sm transition-shadow">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div className="flex items-center gap-2 flex-1 min-w-0">
                    <span className="text-xs font-bold text-slate-400 font-mono w-6">
                      #{idx + 1}
                    </span>

                    <Badge variant="outline" className="text-[10px] px-2 py-0.5 font-bold uppercase bg-slate-100">
                      {resultado.cidade}-{resultado.estado}
                    </Badge>

                    {resultado.isNew && (
                      <Badge className="bg-emerald-600 hover:bg-emerald-700 text-white border-0 text-[10px] px-2 py-0.5 animate-pulse">
                        ⭐ NOVO
                      </Badge>
                    )}

                    {resultado.status === "removed" ? (
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
                      className="text-xs text-primary inline-flex items-center gap-1 hover:underline font-medium bg-slate-50 px-2.5 py-1 rounded border"
                    >
                      Abrir Anúncio na OLX
                      <ExternalLink className="h-3 w-3" />
                    </a>
                    <Button
                      size="sm"
                      variant={leadsSalvosIds.has(resultado.id) ? "secondary" : "outline"}
                      disabled={salvandoId === resultado.id || leadsSalvosIds.has(resultado.id)}
                      onClick={() => handleSalvarLead(resultado)}
                      className="h-7 text-xs gap-1 text-primary hover:bg-primary/10 border-primary/30"
                    >
                      {salvandoId === resultado.id ? (
                        <Loader2 className="h-3 w-3 animate-spin" />
                      ) : leadsSalvosIds.has(resultado.id) ? (
                        <>
                          <CheckCircle className="h-3 w-3 text-green-600" />
                          <span>Salvo</span>
                        </>
                      ) : (
                        <>
                          <PlusCircle className="h-3 w-3" />
                          <span>Salvar Lead</span>
                        </>
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
        </div>
      )}

      {!carregando && resultados.length === 0 && (
        <div className="flex flex-col items-center justify-center py-16 gap-3 text-muted-foreground border rounded-lg bg-white">
          <Building className="h-12 w-12 opacity-20" />
          <p className="text-sm font-medium">
            Nenhum imóvel prospectado sincronizado no momento
          </p>
          <p className="text-xs text-center max-w-xs">
            Execute o Agente Desktop no seu computador para rastrear e enviar imóveis capturados para este painel.
          </p>
        </div>
      )}
    </div>
  );
}
