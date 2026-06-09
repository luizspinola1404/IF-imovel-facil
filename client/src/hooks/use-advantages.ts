import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api, buildUrl } from "@shared/routes";
import { type Advantage, type InsertAdvantage } from "@shared/schema";

// GET /api/advantages
export function useAdvantages() {
  return useQuery({
    queryKey: [api.advantages.list.path],
    queryFn: async () => {
      const res = await fetch(api.advantages.list.path, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch advantages");
      return api.advantages.list.responses[200].parse(await res.json());
    },
  });
}

// GET /api/advantages/:id
export function useAdvantage(id: number) {
  return useQuery({
    queryKey: [api.advantages.get.path, id],
    queryFn: async () => {
      const url = buildUrl(api.advantages.get.path, { id });
      const res = await fetch(url, { credentials: "include" });
      if (res.status === 404) return null;
      if (!res.ok) throw new Error("Failed to fetch advantage");
      return api.advantages.get.responses[200].parse(await res.json());
    },
    enabled: !!id,
  });
}

// POST /api/advantages
export function useCreateAdvantage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (data: InsertAdvantage) => {
      const validated = api.advantages.create.input.parse(data);
      const res = await fetch(api.advantages.create.path, {
        method: api.advantages.create.method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(validated),
        credentials: "include",
      });
      const text = await res.text();
      let parsed: any = null;
      try { parsed = text ? JSON.parse(text) : null; } catch (e) {}
      if (!res.ok) {
        const msg = parsed?.message || res.statusText || `Request failed with status ${res.status}`;
        const err: any = new Error(msg);
        err.status = res.status;
        err.body = parsed;
        throw err;
      }
      const json = parsed ?? JSON.parse(text);
      return api.advantages.create.responses[201].parse(json);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [api.advantages.list.path] }),
  });
}

// PUT /api/advantages/:id
export function useUpdateAdvantage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ...updates }: { id: number } & Partial<InsertAdvantage>) => {
      const validated = api.advantages.update.input.parse(updates);
      const url = buildUrl(api.advantages.update.path, { id });
      const res = await fetch(url, {
        method: api.advantages.update.method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(validated),
        credentials: "include",
      });
      const text = await res.text();
      let parsed: any = null;
      try { parsed = text ? JSON.parse(text) : null; } catch (e) {}
      if (!res.ok) {
        const msg = parsed?.message || res.statusText || `Request failed with status ${res.status}`;
        const err: any = new Error(msg);
        err.status = res.status;
        err.body = parsed;
        throw err;
      }
      const json = parsed ?? JSON.parse(text);
      return api.advantages.update.responses[200].parse(json);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [api.advantages.list.path] }),
  });
}

// DELETE /api/advantages/:id
export function useDeleteAdvantage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: number) => {
      const url = buildUrl(api.advantages.delete.path, { id });
      const res = await fetch(url, { method: api.advantages.delete.method, credentials: "include" });
      if (!res.ok) throw new Error("Failed to delete advantage");
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [api.advantages.list.path] }),
  });
}

// GET /api/properties/:propertyId/advantages
export function usePropertyAdvantages(propertyId: number) {
  return useQuery({
    queryKey: [api.propertyAdvantages.list.path, propertyId],
    queryFn: async () => {
      const url = buildUrl(api.propertyAdvantages.list.path, { propertyId });
      const res = await fetch(url, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch property advantages");
      return api.propertyAdvantages.list.responses[200].parse(await res.json());
    },
    enabled: !!propertyId,
  });
}

// POST /api/properties/:propertyId/advantages
export function useAddPropertyAdvantage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ propertyId, advantageId }: { propertyId: number; advantageId: number }) => {
      const url = buildUrl(api.propertyAdvantages.add.path, { propertyId });
      const res = await fetch(url, {
        method: api.propertyAdvantages.add.method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ advantageId }),
        credentials: "include",
      });
      const text = await res.text();
      let parsed: any = null;
      try { parsed = text ? JSON.parse(text) : null; } catch (e) {}
      if (!res.ok) {
        const msg = parsed?.message || res.statusText || `Request failed with status ${res.status}`;
        const err: any = new Error(msg);
        err.status = res.status;
        err.body = parsed;
        throw err;
      }
      const json = parsed ?? JSON.parse(text);
      return json;
    },
    onSuccess: (_data, { propertyId }) => {
      queryClient.invalidateQueries({ queryKey: [api.propertyAdvantages.list.path, propertyId] });
    },
  });
}

// DELETE /api/properties/:propertyId/advantages/:advantageId
export function useRemovePropertyAdvantage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ propertyId, advantageId }: { propertyId: number; advantageId: number }) => {
      const url = buildUrl(api.propertyAdvantages.remove.path, { propertyId, advantageId });
      const res = await fetch(url, { method: api.propertyAdvantages.remove.method, credentials: "include" });
      if (!res.ok) throw new Error("Failed to remove property advantage");
    },
    onSuccess: (_data, { propertyId }) => {
      queryClient.invalidateQueries({ queryKey: [api.propertyAdvantages.list.path, propertyId] });
    },
  });
}
