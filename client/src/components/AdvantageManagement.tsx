import { useState } from "react";
import { useAdvantages, useDeleteAdvantage } from "@/hooks/use-advantages";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { AlertCircle, Loader2, Plus, Trash2 } from "lucide-react";
import {
  Alert,
  AlertDescription,
} from "@/components/ui/alert";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { AdvantageForm } from "./AdvantageForm";
import { useToast } from "@/hooks/use-toast";
import { AdvantageIcon } from "./AdvantageIcon";

export function AdvantageManagement() {
  const { data: advantages, isLoading, error } = useAdvantages();
  const deleteMutation = useDeleteAdvantage();
  const { toast } = useToast();
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedAdvantage, setSelectedAdvantage] = useState<any>(null);

  const handleDelete = async (id: number) => {
    if (confirm("Tem certeza que deseja deletar esta vantagem?")) {
      try {
        await deleteMutation.mutateAsync(id);
        toast({ title: "Sucesso", description: "Vantagem deletada." });
      } catch (error: any) {
        toast({
          title: "Erro",
          description: error?.message || "Falha ao deletar vantagem.",
          variant: "destructive",
        });
      }
    }
  };

  const handleOpenDialog = (advantage?: any) => {
    setSelectedAdvantage(advantage || null);
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setSelectedAdvantage(null);
  };

  if (isLoading) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center py-8">
          <Loader2 className="h-8 w-8 animate-spin" />
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Alert variant="destructive">
        <AlertCircle className="h-4 w-4" />
        <AlertDescription>
          Erro ao carregar vantagens: {error.message}
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">Vantagens</h2>
        <Dialog open={openDialog} onOpenChange={setOpenDialog}>
          <DialogTrigger asChild>
            <Button onClick={() => handleOpenDialog()} className="gap-2">
              <Plus className="h-4 w-4" />
              Nova Vantagem
            </Button>
          </DialogTrigger>
          <DialogContent className="max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>
                {selectedAdvantage ? "Editar Vantagem" : "Nova Vantagem"}
              </DialogTitle>
              <DialogDescription>
                {selectedAdvantage ? "Atualize os detalhes da vantagem" : "Adicione uma nova vantagem ao sistema"}
              </DialogDescription>
            </DialogHeader>
            <AdvantageForm
              advantage={selectedAdvantage}
              onSuccess={handleCloseDialog}
              onCancel={handleCloseDialog}
            />
          </DialogContent>
        </Dialog>
      </div>

      {advantages?.length === 0 ? (
        <Card>
          <CardContent className="py-8 text-center text-muted-foreground">
            Nenhuma vantagem cadastrada. Comece a adicionar!
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {advantages?.map((advantage: any) => (
            <Card key={advantage.id}>
              <CardHeader>
                <CardTitle className="text-lg flex items-center gap-2">
                  <AdvantageIcon icon={advantage.icon} className="text-lg w-5 text-center text-primary" />
                  {advantage.name}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {advantage.description && (
                  <p className="text-sm text-muted-foreground">
                    {advantage.description}
                  </p>
                )}
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    className="flex-1"
                    onClick={() => handleOpenDialog(advantage)}
                  >
                    Editar
                  </Button>
                  <Button
                    variant="destructive"
                    size="sm"
                    onClick={() => handleDelete(advantage.id)}
                    disabled={deleteMutation.isPending}
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
