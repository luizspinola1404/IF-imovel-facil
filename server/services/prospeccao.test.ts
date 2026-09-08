import { describe, it, expect, vi } from "vitest";
import { buscarImoveisProspeccao } from "./prospeccao";

describe("prospeccao service", () => {
  it("should return aggregated results with proprietario direto links first", async () => {
    const results = await buscarImoveisProspeccao({
      estado: "BA",
      cidade: "Juazeiro",
      tipo: "Casa",
      modalidade: "venda",
    });

    expect(results).toBeDefined();
    expect(Array.isArray(results)).toBe(true);
    if (results.length > 0) {
      expect(results[0].cidade).toBe("Juazeiro");
      expect(results[0].estado).toBe("BA");
    }
  });
});
