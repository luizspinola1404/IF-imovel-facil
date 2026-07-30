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
  Bookmark,
  Loader2,
  Search as SearchIcon,
  Building,
  X,
  PlusCircle,
  Filter,
  CheckCircle,
} from "lucide-react";

const TIPOS = ["Casa", "Apartamento", "Terreno", "Comercial"];
const ESTADOS_BR = [
  "AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG",
  "PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO",
];

interface ScraperResult {
  id: string;
  titulo: string;
  link: string;
  fonte: string;
  trecho: string;
  direto_proprietario: boolean;
  cidade: string;
  estado: string;
  tipo: string;
  modalidade: string;
}

function ResultCard({
  resultado,
  onSalvarLead,
  salvandoId,
  salvo,
}: {
  resultado: ScraperResult;
  onSalvarLead: (r: ScraperResult) => void;
  salvandoId: string | null;
  salvo: boolean;
}) {
  const isSaving = salvandoId === resultado.id;

  return (
    <div className="bg-white border rounded-xl p-4 flex flex-col gap-3 hover:shadow-md transition-shadow">
      <div className="space-y-2">
        <div className="flex flex-wrap gap-2 items-center justify-between">
          <div className="flex flex-wrap gap-2 items-center">
            {resultado.direto_proprietario && (
              <Badge className="bg-green-600 hover:bg-green-700 text-white border-0 text-[10px] px-2 py-0">
                Direto com Proprietário
              </Badge>
            )}
            <Badge variant="outline" className="capitalize text-[10px] px-2 py-0">
              {resultado.modalidade}
            </Badge>
            <span className="text-[10px] text-muted-foreground font-mono">
              {resultado.fonte}
            </span>
          </div>

          <Button
            size="sm"
            variant={salvo ? "secondary" : "outline"}
            disabled={isSaving || salvo}
            onClick={() => onSalvarLead(resultado)}
            className="h-7 text-xs gap-1 text-primary hover:bg-primary/10 border-primary/30"
          >
            {isSaving ? (
              <Loader2 className="h-3 w-3 animate-spin" />
            ) : salvo ? (
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

        <h3 className="font-semibold text-base text-slate-800 leading-tight">
          {resultado.titulo}
        </h3>
        <p className="text-sm text-muted-foreground line-clamp-2">
          {resultado.trecho}
        </p>

        <div className="flex flex-wrap gap-4 pt-1 items-center">
          <a
            href={resultado.link}
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs text-primary inline-flex items-center gap-1 hover:underline font-medium"
          >
            Ver anúncio original
            <ExternalLink className="h-3 w-3" />
          </a>
        </div>
      </div>
    </div>
  );
}

export function ProspeccaoDirect() {
  const { toast } = useToast();
  const [estado, setEstado] = useState("");
  const [cidade, setCidade] = useState("");
  const [tipo, setTipo] = useState("");
  const [modalidade, setModalidade] = useState("");
  const [resultados, setResultados] = useState<ScraperResult[]>([]);
  const [buscando, setBuscando] = useState(false);
  const [salvandoId, setSalvandoId] = useState<string | null>(null);
  const [leadsSalvosIds, setLeadsSalvosIds] = useState<Set<string>>(new Set());
  const [filtroTexto, setFiltroTexto] = useState("");

  // Dynamic cities states
  const [cidades, setCidades] = useState<{ id: number; nome: string }[]>([]);
  const [loadingCidades, setLoadingCidades] = useState(false);

  // Saved searches state
  const [buscasSalvas, setBuscasSalvas] = useState<{
    id: string;
    estado: string;
    cidade: string;
    tipo: string;
    modalidade: string;
  }[]>(() => {
    try {
      const saved = localStorage.getItem("if_imovel_facil_saved_searches");
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  // Fetch cities when estado changes
  useEffect(() => {
    if (!estado) {
      setCidades([]);
      setCidade("");
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

        setCidade((prev) => {
          const exists = sorted.some((c: any) => c.nome.toLowerCase() === prev.toLowerCase());
          return exists ? prev : "";
        });
      } catch (err) {
        console.error(err);
        toast({
          title: "Erro ao buscar cidades",
          description: "Não foi possível conectar à API do IBGE. Você pode digitar a cidade manualmente.",
          variant: "destructive",
        });
        setCidades([]);
      } finally {
        setLoadingCidades(false);
      }
    };

    fetchCidades();
  }, [estado]);

  const handleSalvarBusca = () => {
    if (!estado || !cidade || !tipo || !modalidade) {
      toast({
        title: "Campos incompletos",
        description: "Preencha todos os filtros antes de salvar a busca.",
        variant: "destructive",
      });
      return;
    }

    const duplicate = buscasSalvas.some(
      (b) =>
        b.estado === estado &&
        b.cidade.toLowerCase() === cidade.toLowerCase() &&
        b.tipo === tipo &&
        b.modalidade === modalidade
    );

    if (duplicate) {
      toast({
        title: "Busca já salva",
        description: "Esta combinação de filtros já está nas suas buscas salvas.",
      });
      return;
    }

    const novaBusca = {
      id: Date.now().toString(),
      estado,
      cidade,
      tipo,
      modalidade,
    };

    const atualizadas = [novaBusca, ...buscasSalvas];
    setBuscasSalvas(atualizadas);
    localStorage.setItem("if_imovel_facil_saved_searches", JSON.stringify(atualizadas));

    toast({
      title: "Busca salva com sucesso",
      description: `Busca por ${tipo} em ${cidade}-${estado} (${modalidade}) salva.`,
    });
  };

  const handleDeletarBusca = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    const atualizadas = buscasSalvas.filter((b) => b.id !== id);
    setBuscasSalvas(atualizadas);
    localStorage.setItem("if_imovel_facil_saved_searches", JSON.stringify(atualizadas));
    toast({
      title: "Busca removida",
      description: "Filtro excluído das buscas salvas.",
    });
  };

  const handleCarregarBusca = (busca: typeof buscasSalvas[0]) => {
    setEstado(busca.estado);
    setCidade(busca.cidade);
    setTipo(busca.tipo);
    setModalidade(busca.modalidade);
    toast({
      title: "Busca carregada",
      description: `Filtros para ${busca.cidade}-${busca.estado} aplicados.`,
    });
  };

  const handleBuscar = async () => {
    if (!estado || !cidade || !tipo || !modalidade) {
      toast({
        title: "Preencha todos os campos",
        description: "Estado, cidade, tipo e modalidade são obrigatórios.",
        variant: "destructive",
      });
      return;
    }

    setBuscando(true);
    setResultados([]);
    setFiltroTexto("");

    try {
      const res = await fetch("/api/prospeccao/buscar", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ estado, cidade, tipo, modalidade }),
      });

      if (!res.ok) {
        const errText = await res.text();
        throw new Error(errText || "Erro na busca");
      }

      const data: ScraperResult[] = await res.json();
      setResultados(data);

      toast({
        title: "Busca concluída!",
        description: `${data.length} anúncios/fontes de proprietários diretos encontrados em ${cidade}-${estado}.`,
      });
    } catch (err: any) {
      console.error(err);
      toast({
        title: "Erro na busca",
        description: err.message || "Não foi possível realizar a busca de prospecção.",
        variant: "destructive",
      });
    } finally {
      setBuscando(false);
    }
  };

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
      r.fonte.toLowerCase().includes(query)
    );
  });

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold">Prospecção de Imóveis (Direct proprietário)</h2>
        <p className="text-sm text-muted-foreground">
          Pesquisa por anúncios em portais imobiliários e na web para encontrar listagens de proprietários particulares em tempo real.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 bg-slate-50 p-4 rounded-lg border">
        <div className="space-y-2">
          <Label htmlFor="estado">Estado</Label>
          <Select value={estado} onValueChange={setEstado}>
            <SelectTrigger id="estado">
              <SelectValue placeholder="UF" />
            </SelectTrigger>
            <SelectContent>
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
                <SelectValue placeholder="Selecione a cidade" />
              </SelectTrigger>
              <SelectContent className="max-h-[300px] overflow-y-auto">
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
              placeholder="Digite a cidade"
              value={cidade}
              onChange={(e) => setCidade(e.target.value)}
              disabled={!estado}
            />
          )}
        </div>

        <div className="space-y-2">
          <Label htmlFor="tipo">Tipo</Label>
          <Select value={tipo} onValueChange={setTipo}>
            <SelectTrigger id="tipo">
              <SelectValue placeholder="Tipo" />
            </SelectTrigger>
            <SelectContent>
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
              <SelectValue placeholder="Venda / Aluguel" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="venda">Venda</SelectItem>
              <SelectItem value="aluguel">Aluguel</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="md:col-span-4 flex gap-3 mt-2">
          <Button
            onClick={handleBuscar}
            disabled={buscando}
            className="flex-1 gap-2 bg-primary hover:bg-primary/90"
          >
            {buscando ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Buscando em tempo real...
              </>
            ) : (
              <>
                <SearchIcon className="h-4 w-4" />
                Buscar Proprietários Diretos
              </>
            )}
          </Button>

          <Button
            type="button"
            variant="outline"
            onClick={handleSalvarBusca}
            disabled={buscando}
            className="gap-2 shrink-0 border-slate-300 hover:bg-slate-100"
            title="Salvar esta busca"
          >
            <Bookmark className="h-4 w-4" />
            <span className="hidden sm:inline">Salvar Filtros</span>
          </Button>
        </div>
      </div>

      {buscasSalvas.length > 0 && (
        <div className="bg-slate-50 p-4 rounded-lg border space-y-3">
          <div className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
            Filtros Salvos
          </div>
          <div className="flex flex-wrap gap-2">
            {buscasSalvas.map((busca) => (
              <div
                key={busca.id}
                onClick={() => handleCarregarBusca(busca)}
                className="group flex items-center gap-2 bg-white hover:bg-slate-100 hover:border-slate-300 border rounded-full pl-3 pr-2 py-1 cursor-pointer text-xs font-medium text-slate-700 shadow-sm transition-all"
              >
                <span>
                  {busca.cidade}-{busca.estado} • {busca.tipo} ({busca.modalidade})
                </span>
                <button
                  onClick={(e) => handleDeletarBusca(busca.id, e)}
                  className="text-muted-foreground hover:text-red-500 hover:bg-red-50 rounded-full p-0.5 transition-colors"
                  title="Remover busca"
                >
                  <X className="h-3 w-3" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {buscando && (
        <div className="flex flex-col items-center justify-center py-12 gap-3 text-muted-foreground border rounded-lg bg-white">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
          <p className="text-sm font-medium">Consultando portais imobiliários e listagens de proprietários particulares...</p>
          <p className="text-xs">Isso leva apenas de 1 a 3 segundos.</p>
        </div>
      )}

      {!buscando && resultados.length > 0 && (
        <div className="space-y-4">
          <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-3 px-1">
            <div className="flex items-center gap-2">
              <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                Resultados ({resultadosFiltrados.length} de {resultados.length})
              </span>
              <span className="text-xs text-green-600 bg-green-50 px-2 py-0.5 rounded border border-green-200">
                {resultados.filter((r) => r.direto_proprietario).length} proprietários diretos
              </span>
            </div>

            <div className="relative w-full sm:w-64">
              <Filter className="absolute left-2.5 top-2.5 h-3.5 w-3.5 text-muted-foreground" />
              <Input
                placeholder="Filtrar nos resultados..."
                value={filtroTexto}
                onChange={(e) => setFiltroTexto(e.target.value)}
                className="pl-8 h-8 text-xs bg-white"
              />
            </div>
          </div>

          <div className="grid gap-4">
            {resultadosFiltrados.map((resultado) => (
              <ResultCard
                key={resultado.id}
                resultado={resultado}
                onSalvarLead={handleSalvarLead}
                salvandoId={salvandoId}
                salvo={leadsSalvosIds.has(resultado.id)}
              />
            ))}
          </div>
        </div>
      )}

      {!buscando && resultados.length === 0 && (
        <div className="flex flex-col items-center justify-center py-16 gap-3 text-muted-foreground border rounded-lg bg-white">
          <Building className="h-12 w-12 opacity-20" />
          <p className="text-sm font-medium">Nenhuma busca ativa</p>
          <p className="text-xs text-center max-w-xs">
            Selecione a localização e o tipo de imóvel nos filtros acima e execute a busca para rastrear leads particulares.
          </p>
        </div>
      )}
    </div>
  );
}
