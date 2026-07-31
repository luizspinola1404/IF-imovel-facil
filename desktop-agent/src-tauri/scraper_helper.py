import json
import math
import re
import sys
import urllib.request

MAPA_TIPOS = {
    "casa": "casas",
    "casas": "casas",
    "apartamento": "apartamentos",
    "apartamentos": "apartamentos",
    "terreno": "terrenos-e-lotes",
    "terrenos": "terrenos-e-lotes",
    "lote": "terrenos-e-lotes",
    "lotes": "terrenos-e-lotes",
    "comercial": "comercio-e-industria",
    "sala": "comercio-e-industria",
    "galpao": "comercio-e-industria",
    "imoveis": "imoveis",
    "todos": ""
}

def normalizar(texto: str) -> str:
    subs = {
        'ã': 'a', 'á': 'a', 'â': 'a', 'é': 'e', 'ê': 'e',
        'í': 'i', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ç': 'c'
    }
    res = texto.lower()
    for k, v in subs.items():
        res = res.replace(k, v)
    return "+".join(res.split())

def construir_url_olx(estado: str, tipo_imovel: str, modalidade: str = "venda", cidade: str = "", apenas_particular: bool = True) -> str:
    cidade_input = cidade.strip()
    if cidade_input.startswith("http://") or cidade_input.startswith("https://"):
        url = cidade_input
        if apenas_particular and "f=p" not in url:
            sep = "&" if "?" in url else "?"
            url = f"{url}{sep}f=p"
        return url

    st = estado.lower().replace("estado-", "").strip()
    uf_param = f"estado-{st}" if st not in ["br", "todos", "all"] else ""

    tipo_slug = MAPA_TIPOS.get(tipo_imovel.lower().strip(), tipo_imovel.lower().strip())
    mod_slug = modalidade.lower().strip()

    parts = ["https://www.olx.com.br/imoveis", mod_slug]
    if tipo_slug and tipo_slug != "imoveis":
        parts.append(tipo_slug)
    if uf_param:
        parts.append(uf_param)

    url = "/".join(parts)
    params = []
    if apenas_particular:
        params.append("f=p")
    if cidade_input:
        clean_city = normalizar(cidade_input)
        params.append(f"q={clean_city}")

    if params:
        url += "?" + "&".join(params)

    return url

def fetch_html(url: str) -> str:
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7",
        }
    )
    return urllib.request.urlopen(req, timeout=15).read().decode('utf-8')

def raspar_links_de_url_olx(url: str, cidade: str = "", estado: str = "") -> list:
    if "f=p" not in url:
        sep = "&" if "?" in url else "?"
        url = f"{url}{sep}f=p"

    html_inicial = fetch_html(url)
    todos_os_items = []
    seen = set()

    pattern_href = r'href="(https://[a-z0-9\.-]*olx\.com\.br/[^"]*?-\d+)"'
    full_matches = re.finditer(pattern_href, html_inicial)
    for m in full_matches:
        link = m.group(1)
        if link not in seen and not link.endswith(('.png', '.jpg', '.ico')):
            seen.add(link)
            slug = link.split('/')[-1]
            titulo_raw = slug.rsplit('-', 1)[0].replace('-', ' ').title()
            todos_os_items.append({
                "id": f"olx-{len(todos_os_items)+1}",
                "titulo": titulo_raw or f"Imóvel Particular em {cidade}-{estado}",
                "link": link,
                "fonte": "OLX Brasil (Particular)",
                "trecho": f"Imóvel de proprietário particular capturado em {cidade}-{estado}.",
                "direto_proprietario": True
            })

    if not todos_os_items:
        raw_urls = re.findall(r'https://[a-z0-9\.-]*olx\.com\.br/[^"\'\s]*?-\d+', html_inicial)
        for link in raw_urls:
            if link not in seen and not link.endswith(('.png', '.jpg', '.ico')):
                seen.add(link)
                slug = link.split('/')[-1]
                titulo_raw = slug.rsplit('-', 1)[0].replace('-', ' ').title()
                todos_os_items.append({
                    "id": f"olx-{len(todos_os_items)+1}",
                    "titulo": titulo_raw or f"Imóvel Particular em {cidade}-{estado}",
                    "link": link,
                    "fonte": "OLX Brasil (Particular)",
                    "trecho": f"Imóvel de proprietário particular capturado em {cidade}-{estado}.",
                    "direto_proprietario": True
                })

    return todos_os_items

def main():
    estado = sys.argv[1] if len(sys.argv) > 1 else "ES"
    cidade = sys.argv[2] if len(sys.argv) > 2 else "São Mateus"
    tipo = sys.argv[3] if len(sys.argv) > 3 else "Casa"
    modalidade = sys.argv[4] if len(sys.argv) > 4 else "venda"

    url_gerada = construir_url_olx(estado, tipo, modalidade, cidade, apenas_particular=True)

    try:
        items = raspar_links_de_url_olx(url_gerada, cidade=cidade, estado=estado)
        print(json.dumps({"success": True, "target_url": url_gerada, "items": items}))
    except Exception as e:
        print(json.dumps({"success": False, "target_url": url_gerada, "error": str(e), "items": []}))

if __name__ == "__main__":
    main()
