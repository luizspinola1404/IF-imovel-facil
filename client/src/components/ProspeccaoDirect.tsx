import { useState } from "react";
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
import { ExternalLink, Bookmark, BookmarkCheck, Loader2, Search as SearchIcon, Building } from "lucide-react";
import { useQueryClient } from "@tanstack/react-query";
import { api } from "@shared/routes";

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

export function ProspeccaoDirect() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [estado, setEstado] = useState("");
  const [cidade, setCidade] = useState("");
  const [tipo, setTipo] = useState("");
  const [modalidade, setModalidade] = useState("");
  const [resultados, setResultados] = useState<ScraperResult[]>([]);
  const [buscando, setBuscando] = useState(false);
  const [salvandoId, setSalvandoId] = useState<string | null>(null);
  const [salvos, setSalvos] = useState<Set<string>>(new Set());

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
    setSalvos(new Set());

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

      const data = await res.json();
      setResultados(data);

      if (data.length === 0) {
        toast({
          title: "Nenhum resultado encontrado",
          description: "Tente termos diferentes ou mude a modalidade de busca.",
        });
      }
    } catch (err: any) {
      console.error(err);
      toast({
        title: "Erro na busca",
        description: err.message || "Não foi possível conectar ao robô de busca. Certifique-se de que o geckodriver está disponível.",
        variant: "destructive",
      });
    } finally {
      setBuscando(false);
    }
  };

  const handleSalvar = async (resultado: ScraperResult) => {
    setSalvandoId(resultado.id);

    try {
      const res = await fetch("/api/prospeccao/salvar-lead", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(resultado),
      });

      if (!res.ok) {
        const errText = await res.text();
        throw new Error(errText || "Erro ao salvar lead");
      }

      setSalvos((prev) => new Set([...prev, resultado.id]));
      toast({
        title: "Lead salvo",
        description: "O imóvel foi adicionado com sucesso à sua listagem principal.",
      });

      // Invalida a query de listagem de imóveis para atualizar a tabela principal
      queryClient.invalidateQueries({ queryKey: [api.properties.list.path] });
    } catch (err: any) {
      console.error(err);
      toast({
        title: "Erro ao salvar lead",
        description: err.message || "Não foi possível importar este lead para o banco de dados.",
        variant: "destructive",
      });
    } finally {
      setSalvandoId(null);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold">Prospecção de Imóveis (Direct proprietário)</h2>
        <p className="text-sm text-muted-foreground">
          Pesquisa por anúncios em portais imobiliários utilizando automação para encontrar listagens de proprietários particulares.
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
          <Input
            id="cidade"
            placeholder="Ex: Juazeiro"
            value={cidade}
            onChange={(e) => setCidade(e.target.value)}
          />
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

        <Button
          onClick={handleBuscar}
          disabled={buscando}
          className="md:col-span-4 w-full gap-2 mt-2"
        >
          {buscando ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Buscando no DuckDuckGo (iniciando driver oculto)...
            </>
          ) : (
            <>
              <SearchIcon className="h-4 w-4" />
              Buscar Proprietários Diretos
            </>
          )}
        </Button>
      </div>

      {buscando && (
        <div className="flex flex-col items-center justify-center py-12 gap-3 text-muted-foreground border rounded-lg bg-white">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
          <p className="text-sm font-medium">Iniciando o navegador e executando buscas de prospecção...</p>
          <p className="text-xs">Isso pode levar de 5 a 20 segundos enquanto a automação filtra os anúncios.</p>
        </div>
      )}

      {!buscando && resultados.length > 0 && (
        <div className="space-y-3">
          <div className="flex justify-between items-center px-1">
            <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
              Resultados da prospecção ({resultados.length})
            </span>
            <span className="text-xs text-green-600 bg-green-50 px-2 py-0.5 rounded border border-green-200">
              {resultados.filter((r) => r.direto_proprietario).length} identificados como proprietário direto
            </span>
          </div>

          <div className="grid gap-4">
            {resultados.map((resultado) => {
              const isSaved = salvos.has(resultado.id);
              const isSaving = salvandoId === resultado.id;

              return (
                <div
                  key={resultado.id}
                  className="bg-white border rounded-xl p-4 flex flex-col md:flex-row justify-between gap-4 hover:shadow-md transition-shadow"
                >
                  <div className="space-y-2 flex-1">
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

                    <h3 className="font-semibold text-base text-slate-800 leading-tight">
                      {resultado.titulo}
                    </h3>
                    <p className="text-sm text-muted-foreground line-clamp-2">
                      {resultado.trecho}
                    </p>

                    <a
                      href={resultado.link}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-xs text-primary inline-flex items-center gap-1 hover:underline"
                    >
                      Ver anúncio original
                      <ExternalLink className="h-3 w-3" />
                    </a>
                  </div>

                  <div className="flex items-center shrink-0">
                    <Button
                      onClick={() => handleSalvar(resultado)}
                      disabled={isSaved || isSaving}
                      variant={isSaved ? "secondary" : "outline"}
                      className="w-full md:w-auto gap-2"
                    >
                      {isSaving ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : isSaved ? (
                        <BookmarkCheck className="h-4 w-4 text-green-600" />
                      ) : (
                        <Bookmark className="h-4 w-4" />
                      )}
                      {isSaved ? "Salvo na Lista" : "Salvar Lead"}
                    </Button>
                  </div>
                </div>
              );
            })}
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
