import json
import math
import re
import sys
import urllib.request
from datetime import datetime, timedelta

try:
    from curl_cffi import requests as cffi_requests
except ImportError:
    cffi_requests = None


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
    if cffi_requests is not None:
        resp = cffi_requests.get(url, impersonate="chrome124", timeout=20)
        if resp.status_code == 200:
            return resp.text
        raise RuntimeError(f"HTTP {resp.status_code}: {resp.reason}")

    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7",
        }
    )
    return urllib.request.urlopen(req, timeout=15).read().decode('utf-8')

MAPA_MESES = {
    'jan': 1, 'fev': 2, 'mar': 3, 'abr': 4, 'mai': 5, 'jun': 6,
    'jul': 7, 'ago': 8, 'set': 9, 'out': 10, 'nov': 11, 'dez': 12,
    'janeiro': 1, 'fevereiro': 2, 'março': 3, 'abril': 4, 'maio': 5, 'junho': 6,
    'julho': 7, 'agosto': 8, 'setembro': 9, 'outubro': 10, 'novembro': 11, 'dezembro': 12
}

def parse_olx_date(date_str: str):
    if not date_str:
        return datetime.now().isoformat(), None
    
    # Limpa tags HTML, comentários <!-- --> e espaços inquebráveis (&nbsp;, \xa0)
    raw = re.sub(r'<[^>]+>', '', date_str).replace('&nbsp;', ' ').replace('\xa0', ' ').strip()
    if not raw:
        return datetime.now().isoformat(), None

    clean = raw.lower()
    now = datetime.now()

    if "hoje" in clean:
        m_time = re.search(r'(\d{1,2}):(\d{2})', clean)
        hour = int(m_time.group(1)) if m_time else now.hour
        minute = int(m_time.group(2)) if m_time else now.minute
        dt = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
        return dt.isoformat(), raw

    if "ontem" in clean:
        m_time = re.search(r'(\d{1,2}):(\d{2})', clean)
        hour = int(m_time.group(1)) if m_time else now.hour
        minute = int(m_time.group(2)) if m_time else now.minute
        dt = (now - timedelta(days=1)).replace(hour=hour, minute=minute, second=0, microsecond=0)
        return dt.isoformat(), raw

    # Ex: "22 de set, 17:17" ou "22 de set., 17:17" ou "22 de setembro 17:17"
    m_fixed = re.search(r'(\d{1,2})\s*(?:de)?\s*([a-z]{3,9})\.?\s*,?\s*(?:(\d{1,2}):(\d{2}))?', clean)
    if m_fixed:
        day = int(m_fixed.group(1))
        mes_str = m_fixed.group(2)
        month = MAPA_MESES.get(mes_str, now.month)
        hour = int(m_fixed.group(3)) if m_fixed.group(3) is not None else 12
        minute = int(m_fixed.group(4)) if m_fixed.group(4) is not None else 0
        year = now.year
        if month > now.month:
            year -= 1
        try:
            dt = datetime(year, month, day, hour, minute, 0)
            return dt.isoformat(), raw
        except ValueError:
            pass

    return now.isoformat(), raw

def raspar_links_de_url_olx(url: str, cidade: str = "", estado: str = "") -> list:
    if "f=p" not in url:
        sep = "&" if "?" in url else "?"
        url = f"{url}{sep}f=p"

    html_inicial = fetch_html(url)

    total_imoveis = 0
    m = re.search(r'de\s+([\d\.]+)\s+resultados', html_inicial, re.IGNORECASE) or re.search(r'([\d\.]+)\s+resultados', html_inicial, re.IGNORECASE)
    if m:
        try:
            total_imoveis = int(m.group(1).replace('.', ''))
        except Exception:
            total_imoveis = 0

    total_paginas = math.ceil(total_imoveis / 50) if total_imoveis > 0 else 1
    max_paginas = 1 if total_imoveis == 0 else min(total_paginas, 3)

    todos_os_items = []
    seen = set()

    for pagina in range(1, max_paginas + 1):
        if pagina == 1:
            html = html_inicial
        else:
            sep = "&" if "?" in url else "?"
            url_pag = f"{url}{sep}o={pagina}"
            try:
                html = fetch_html(url_pag)
            except Exception:
                break

        cards = re.split(r'<section[^>]*class=["\x27][^"\x27]*olx-adcard', html)
        novos_na_pagina = 0

        for card in cards[1:]:
            m_link = re.search(r'href=["\x27](https://[^\s"\x27]*olx\.com\.br/[^"\x27]*-\d+)["\x27]', card)
            if not m_link:
                continue

            link = m_link.group(1)
            if link in seen or link.endswith(('.png', '.jpg', '.ico')):
                continue

            seen.add(link)
            novos_na_pagina += 1

            slug = link.split('/')[-1]
            slug_title = slug.rsplit('-', 1)[0].replace('-', ' ').title()

            m_title = re.search(r'class=["\x27][^"\x27]*olx-adcard__title[^"\x27]*["\x27]>([^<]+)<', card)
            titulo = m_title.group(1).strip() if m_title else slug_title

            m_price = re.search(r'class=["\x27][^"\x27]*olx-adcard__price[^"\x27]*["\x27]>([^<]+)<', card)
            preco = m_price.group(1).strip() if m_price else None

            m_date = re.search(r'olx-adcard__date[^>]*>([^<]+)<', card)
            data_raw = m_date.group(1).strip() if m_date else ""
            published_at_iso, data_raw_clean = parse_olx_date(data_raw)

            m_loc = re.search(r'olx-adcard__location[^>]*>(?:<svg[^>]*>.*?</svg>)?\s*(?:<!--\s*-->)?\s*([^<]+)<', card, re.DOTALL)
            localizacao = m_loc.group(1).strip() if m_loc else f"{cidade}, {estado}"

            todos_os_items.append({
                "id": f"olx-{slug}" if slug else f"olx-{abs(hash(link))}",
                "titulo": titulo or f"Imóvel Particular em {cidade}-{estado}",
                "link": link,
                "preco": preco,
                "localizacao": localizacao,
                "fonte": "OLX Brasil (Particular)",
                "trecho": f"{titulo} ({preco or 'Sob consulta'}) em {localizacao}.",
                "direto_proprietario": True,
                "published_at": published_at_iso,
                "data_publicacao_raw": data_raw_clean or data_raw
            })

        # Se não encontrou novos imóveis nesta página, interrompe o loop imediatamente
        if novos_na_pagina == 0:
            break

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
