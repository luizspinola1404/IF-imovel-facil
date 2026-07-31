import math
import re
import time
from selenium import webdriver
from bs4 import BeautifulSoup

# Mapeamento de termos amigáveis para as categorias da OLX
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


def construir_url_olx(estado: str, tipo_imovel: str, modalidade: str = "venda", apenas_particular: bool = True) -> str:
    """
    Gera a URL formatada da OLX com base no estado, tipo de imóvel e modalidade.
    Exemplo: construir_url_olx('es', 'casa', 'venda') 
    -> 'https://www.olx.com.br/imoveis/venda/casas/estado-es?f=p'
    """
    st = estado.lower().replace("estado-", "").strip()
    uf_param = f"estado-{st}" if st not in ["br", "todos", "all"] else ""
    
    tipo_slug = MAPA_TIPOS.get(tipo_imovel.lower().strip(), tipo_imovel.lower().strip())
    mod_slug = modalidade.lower().strip()  # 'venda' ou 'aluguel'
    
    parts = ["https://www.olx.com.br/imoveis", mod_slug]
    if tipo_slug and tipo_slug != "imoveis":
        parts.append(tipo_slug)
    if uf_param:
        parts.append(uf_param)
        
    url = "/".join(parts)
    if apenas_particular:
        url += "?f=p"
        
    return url


def raspar_imoveis_olx(estado: str, tipo_imovel: str, modalidade: str = "venda", apenas_particular: bool = True, driver=None) -> list[str]:
    """
    Recebe o estado (ex: 'ES', 'SP', 'MG') e o tipo de imóvel (ex: 'casa', 'apartamento', 'terreno')
    e retorna uma lista contendo todos os links dos imóveis encontrados.
    """
    url_base = construir_url_olx(estado, tipo_imovel, modalidade, apenas_particular)
    print(f"URL Alvo: {url_base}")
    
    should_close_driver = False
    if driver is None:
        driver = webdriver.Chrome()
        should_close_driver = True

    driver.get(url_base)
    time.sleep(3)
    
    soup_inicial = BeautifulSoup(driver.page_source, 'html.parser')
    padrao_total = re.compile(r'de\s+(\d+)\s+resultados', re.IGNORECASE)
    elemento_total = soup_inicial.find(string=re.compile(r'resultados', re.IGNORECASE))
    
    total_imoveis = 0
    if elemento_total and (match := padrao_total.search(elemento_total)):
        total_imoveis = int(match.group(1))
    
    total_paginas = math.ceil(total_imoveis / 50) if total_imoveis > 0 else 1
    print(f"Encontrados {total_imoveis} imóveis ({total_paginas} páginas) para {tipo_imovel} em {estado.upper()}.")
    
    todos_os_links = []
    
    for pagina in range(1, total_paginas + 1):
        if pagina == 1:
            url_pagina = url_base
        else:
            sep = "&" if "?" in url_base else "?"
            url_pagina = f"{url_base}{sep}o={pagina}"
            
        print(f"Raspando página {pagina}/{total_paginas}: {url_pagina}")
        if pagina > 1:
            driver.get(url_pagina)
            time.sleep(3)
            
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        for a in soup.find_all('a', href=True):
            href = a['href']
            if 'olx.com.br' in href and '/imoveis/' in href and re.search(r'-\d+$', href):
                if href not in todos_os_links:
                    todos_os_links.append(href)
                    
        print(f"-> Total acumulado: {len(todos_os_links)} links.")
        
    if should_close_driver:
        driver.quit()
        
    return todos_os_links


if __name__ == "__main__":
    # Exemplo de chamada da função:
    estado_desejado = "ES"
    tipo_desejado = "casa"
    
    links = raspar_imoveis_olx(estado=estado_desejado, tipo_imovel=tipo_desejado, modalidade="venda")

    
    print("\n==========================================")
    print(f"TOTAL DE LINKS EXTRAÍDOS: {len(links)}")
    print("==========================================")
    for idx, item in enumerate(links, 1):
        print(f"{idx:02d}. {item}")
