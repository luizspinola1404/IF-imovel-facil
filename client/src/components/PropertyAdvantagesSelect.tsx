import { useAdvantages, usePropertyAdvantages, useAddPropertyAdvantage, useRemovePropertyAdvantage } from "@/hooks/use-advantages";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { AdvantageIcon } from "./AdvantageIcon";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { Loader2, X } from "lucide-react";

interface PropertyAdvantagesSelectProps {
  propertyId?: number;
  onChanged?: () => void;
}

export function PropertyAdvantagesSelect({ propertyId, onChanged }: PropertyAdvantagesSelectProps) {
  const { toast } = useToast();
  const { data: allAdvantages, isLoading: isLoadingAdvantages } = useAdvantages();
  const { data: propertyAdvantages, isLoading: isLoadingProperty } = usePropertyAdvantages(propertyId || 0);
  const addMutation = useAddPropertyAdvantage();
  const removeMutation = useRemovePropertyAdvantage();

  const isLoading = isLoadingAdvantages || isLoadingProperty;

  const selectedIds = new Set(propertyAdvantages?.map((a: any) => a.id) || []);
  const availableAdvantages = allAdvantages?.filter((a: any) => !selectedIds.has(a.id)) || [];

  const handleAdd = async (advantageId: number) => {
    if (!propertyId) {
      toast({
        title: "Aviso",
        description: "Salve a propriedade primeiro para adicionar vantagens.",
        variant: "destructive",
      });
      return;
    }

    try {
      await addMutation.mutateAsync({ propertyId, advantageId });
      toast({ title: "Sucesso", description: "Vantagem adicionada." });
      onChanged?.();
    } catch (error: any) {
      toast({
        title: "Erro",
        description: error?.message || "Falha ao adicionar vantagem.",
        variant: "destructive",
      });
    }
  };

  const handleRemove = async (advantageId: number) => {
    if (!propertyId) return;

    try {
      await removeMutation.mutateAsync({ propertyId, advantageId });
      toast({ title: "Sucesso", description: "Vantagem removida." });
      onChanged?.();
    } catch (error: any) {
      toast({
        title: "Erro",
        description: error?.message || "Falha ao remover vantagem.",
        variant: "destructive",
      });
    }
  };

  if (!propertyId) {
    return (
      <div className="text-sm text-muted-foreground">
        Salve a propriedade primeiro para adicionar vantagens.
      </div>
    );
  }

  if (isLoading) {
    return <Loader2 className="h-4 w-4 animate-spin" />;
  }

  return (
    <div className="space-y-3">
      <div className="flex gap-2 items-end">
        <Select
          onValueChange={(advantageId) => handleAdd(Number(advantageId))}
        >
          <SelectTrigger className="flex-1">
            <SelectValue placeholder="Adicionar vantagem..." />
          </SelectTrigger>
          <SelectContent>
            {availableAdvantages.length === 0 ? (
              <div className="p-2 text-sm text-muted-foreground">
                Nenhuma vantagem disponível
              </div>
            ) : (
              availableAdvantages.map((advantage: any) => (
                <SelectItem key={advantage.id} value={String(advantage.id)}>
                  <span className="flex items-center gap-2">
                    <AdvantageIcon icon={advantage.icon} className="w-4 text-center text-primary" />
                    <span>{advantage.name}</span>
                  </span>
                </SelectItem>
              ))
            )}
          </SelectContent>
        </Select>
      </div>

      {propertyAdvantages && propertyAdvantages.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {propertyAdvantages.map((advantage: any) => (
            <Badge key={advantage.id} variant="secondary" className="gap-2 py-1.5">
              <AdvantageIcon icon={advantage.icon} className="w-4 text-center text-primary" />
              {advantage.name}
              <button
                onClick={() => handleRemove(advantage.id)}
                disabled={removeMutation.isPending}
                className="ml-1 hover:text-red-500"
              >
                <X className="h-3 w-3" />
              </button>
            </Badge>
          ))}
        </div>
      )}
    </div>
  );
}
