import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { insertAdvantageSchema, type InsertAdvantage } from "@shared/schema";
import { useCreateAdvantage, useUpdateAdvantage } from "@/hooks/use-advantages";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { useToast } from "@/hooks/use-toast";
import { z } from "zod";

const formSchema = insertAdvantageSchema;

type FormValues = z.infer<typeof formSchema>;

interface AdvantageFormProps {
  advantage?: any;
  onSuccess?: () => void;
  onCancel?: () => void;
}

export function AdvantageForm({ advantage, onSuccess, onCancel }: AdvantageFormProps) {
  const { toast } = useToast();
  const createMutation = useCreateAdvantage();
  const updateMutation = useUpdateAdvantage();

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: advantage?.name || "",
      description: advantage?.description || "",
      icon: advantage?.icon || "",
    },
  });

  const onSubmit = async (data: FormValues) => {
    try {
      if (advantage) {
        await updateMutation.mutateAsync({ id: advantage.id, ...data });
        toast({ title: "Sucesso", description: "Vantagem atualizada." });
      } else {
        await createMutation.mutateAsync(data);
        toast({ title: "Sucesso", description: "Vantagem cadastrada." });
      }
      onSuccess?.();
    } catch (error: any) {
      console.error("Save advantage error:", error);
      const message = error?.message || error?.body?.message || "Falha ao salvar vantagem. Verifique os dados.";
      toast({
        title: "Erro",
        description: message,
        variant: "destructive",
      });
    }
  };

  const isPending = createMutation.isPending || updateMutation.isPending;

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 py-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Nome da Vantagem</FormLabel>
              <FormControl>
                <Input placeholder="Ex: Piscina" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Descrição (opcional)</FormLabel>
              <FormControl>
                <Textarea placeholder="Descreva a vantagem..." rows={3} {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="icon"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Ícone/Emoji (opcional)</FormLabel>
              <FormControl>
                <Input placeholder="Ex: 🏊 ou Pool" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="flex justify-end gap-2">
          <Button
            type="button"
            variant="outline"
            onClick={onCancel}
            disabled={isPending}
          >
            Cancelar
          </Button>
          <Button type="submit" disabled={isPending}>
            {isPending ? (advantage ? "Atualizando..." : "Cadastrando...") : (advantage ? "Atualizar" : "Cadastrar")}
          </Button>
        </div>
      </form>
    </Form>
  );
}
