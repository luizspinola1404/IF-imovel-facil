use thirtyfour::prelude::*;
use serde::{Serialize, Deserialize};
use std::process::Command;
use std::thread;
use std::time::Duration;
use regex::Regex;

#[derive(Serialize, Deserialize, Debug, Clone)]
struct SearchResult {
    id: String,
    titulo: String,
    link: String,
    fonte: String,
    trecho: String,
    direto_proprietario: bool,
    cidade: String,
    estado: String,
    tipo: String,
    modalidade: String,
}

fn mapear_tipo_imovel(tipo: &str) -> String {
    let lower = tipo.to_lowercase();
    match lower.as_str() {
        "casa" | "casas" => "casas".to_string(),
        "apartamento" | "apartamentos" | "ap" => "apartamentos".to_string(),
        "terreno" | "terrenos" | "lote" | "lotes" => "terrenos-e-lotes".to_string(),
        "comercial" | "sala" | "galpão" | "galpao" => "comercio-e-industria".to_string(),
        "imoveis" | "todos" => "imoveis".to_string(),
        _ => lower,
    }
}

fn normalizar_cidade(cidade: &str) -> String {
    let unaccented = cidade
        .to_lowercase()
        .chars()
        .map(|c| match c {
            'á' | 'à' | 'ã' | 'â' | 'ä' => 'a',
            'é' | 'è' | 'ê' | 'ë' => 'e',
            'í' | 'ì' | 'î' | 'ï' => 'i',
            'ó' | 'ò' | 'õ' | 'ô' | 'ö' => 'o',
            'ú' | 'ù' | 'û' | 'ü' => 'u',
            'ç' => 'c',
            other => other,
        })
        .collect::<String>();

    unaccented
        .trim()
        .split_whitespace()
        .collect::<Vec<&str>>()
        .join("+")
}

fn construir_url_olx(estado: &str, cidade: &str, tipo: &str, modalidade: &str) -> String {
    let st = estado.to_lowercase().replace("estado-", "");
    let uf_param = if st != "br" && st != "todos" && !st.is_empty() {
        format!("estado-{}", st)
    } else {
        String::new()
    };

    let tipo_slug = mapear_tipo_imovel(tipo);
    let mod_slug = if modalidade.to_lowercase() == "aluguel" { "aluguel" } else { "venda" };

    let mut parts = vec!["https://www.olx.com.br/imoveis", mod_slug];
    if !tipo_slug.is_empty() && tipo_slug != "imoveis" {
        parts.push(&tipo_slug);
    }
    if !uf_param.is_empty() {
        parts.push(&uf_param);
    }

    let url_base = parts.join("/");

    let mut query_params = vec!["f=p".to_string()];
    if !cidade.trim().is_empty() {
        let clean_city = normalizar_cidade(cidade);
        query_params.push(format!("q={}", clean_city));
    }

    format!("{}?{}", url_base, query_params.join("&"))
}

fn preparar_url_com_particular(url: &str) -> String {
    if !url.contains("f=p") {
        let sep = if url.contains('?') { "&" } else { "?" };
        format!("{}{}", url, sep) + "f=p"
    } else {
        url.to_string()
    }
}

fn gerar_id(titulo: &str, link: &str) -> String {
    let raw = format!("{}{}", titulo, link);
    let mut hash: i32 = 0;
    for c in raw.chars() {
        let char_code = c as i32;
        hash = (hash.wrapping_shl(5)).wrapping_sub(hash).wrapping_add(char_code);
    }
    format!("{:x}", hash.abs())
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1. Parse CLI Arguments
    let args: Vec<String> = std::env::args().collect();
    let mut custom_url = String::new();
    let mut cidade = String::new();
    let mut estado = String::new();
    let mut tipo = String::new();
    let mut modalidade = String::new();

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--url" => {
                if i + 1 < args.len() {
                    custom_url = args[i + 1].clone();
                    i += 2;
                } else { i += 1; }
            }
            "--cidade" => {
                if i + 1 < args.len() {
                    cidade = args[i + 1].clone();
                    i += 2;
                } else { i += 1; }
            }
            "--estado" => {
                if i + 1 < args.len() {
                    estado = args[i + 1].clone();
                    i += 2;
                } else { i += 1; }
            }
            "--tipo" => {
                if i + 1 < args.len() {
                    tipo = args[i + 1].clone();
                    i += 2;
                } else { i += 1; }
            }
            "--modalidade" => {
                if i + 1 < args.len() {
                    modalidade = args[i + 1].clone();
                    i += 2;
                } else { i += 1; }
            }
            _ => i += 1,
        }
    }

    let target_url = if !custom_url.is_empty() {
        preparar_url_com_particular(&custom_url)
    } else if !estado.is_empty() && !tipo.is_empty() && !modalidade.is_empty() {
        construir_url_olx(&estado, &cidade, &tipo, &modalidade)
    } else {
        eprintln!("Erro: Forneça --url <url> ou --cidade <cidade> --estado <estado> --tipo <tipo> --modalidade <modalidade>");
        std::process::exit(1);
    };

    // 2. Inicia o Geckodriver em segundo plano em uma porta dinâmica
    let pid = std::process::id();
    let port_num = 4500 + (pid % 1000);
    let port = port_num.to_string();
    let mut geckodriver = Command::new("geckodriver")
        .arg("--port")
        .arg(&port)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("Falha ao iniciar o Geckodriver");

    thread::sleep(Duration::from_millis(1500));

    // 3. Configura o WebDriver do thirtyfour com User-Agent de navegador real
    let mut caps = DesiredCapabilities::firefox();
    caps.add_arg("--headless")?;
    caps.add_arg("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36")?;

    let driver_url = format!("http://localhost:{}", port);
    let driver = match WebDriver::new(&driver_url, caps).await {
        Ok(d) => d,
        Err(e) => {
            let _ = geckodriver.kill();
            eprintln!("Erro ao conectar com o WebDriver: {}", e);
            std::process::exit(1);
        }
    };

    // 4. Configura listener de sinais SIGTERM / SIGINT
    let (tx, mut rx) = tokio::sync::oneshot::channel::<()>();
    tokio::spawn(async move {
        #[cfg(unix)]
        {
            use tokio::signal::unix::{signal, SignalKind};
            if let (Ok(mut sigterm), Ok(mut sigint)) = (
                signal(SignalKind::terminate()),
                signal(SignalKind::interrupt()),
            ) {
                tokio::select! {
                    _ = sigterm.recv() => {}
                    _ = sigint.recv() => {}
                }
            } else {
                let _ = tokio::signal::ctrl_c().await;
            }
        }
        #[cfg(not(unix))]
        {
            let _ = tokio::signal::ctrl_c().await;
        }
        let _ = tx.send(());
    });

    // 5. Executa a raspagem nativa na OLX com filtro f=p e paginação
    let res = tokio::select! {
        r = async {
            let mut results: Vec<SearchResult> = Vec::new();
            let mut seen_links = std::collections::HashSet::new();

            if driver.goto(&target_url).await.is_ok() {
                tokio::time::sleep(Duration::from_millis(3000)).await;

                let page_html = driver.source().await.unwrap_or_default();
                let re_total = Regex::new(r"(?i)de\s+(\d+)\s+resultados")?;
                
                let total_items = if let Some(cap) = re_total.captures(&page_html) {
                    cap.get(1).and_then(|m| m.as_str().parse::<usize>().ok()).unwrap_or(0)
                } else {
                    0
                };

                let total_pages = if total_items > 0 {
                    (total_items + 49) / 50
                } else {
                    1
                };

                let re_ad_id = Regex::new(r"-\d+$")?;

                for page in 1..=total_pages {
                    if page > 1 {
                        let sep = if target_url.contains('?') { "&" } else { "?" };
                        let page_url = format!("{}{}&o={}", target_url, sep, page);
                        if driver.goto(&page_url).await.is_err() {
                            break;
                        }
                        tokio::time::sleep(Duration::from_millis(3000)).await;
                    }

                    if let Ok(anchors) = driver.find_all(By::Tag("a")).await {
                        for a in anchors {
                            if let Ok(Some(href)) = a.attr("href").await {
                                if href.contains("olx.com.br") && href.contains("/imoveis/") && re_ad_id.is_match(&href) {
                                    if !seen_links.contains(&href) {
                                        seen_links.insert(href.clone());
                                        let title = a.text().await.unwrap_or_default();
                                        let clean_title = if title.trim().is_empty() {
                                            format!("Imóvel Direto com Proprietário em {}", se_nao_vazio(&cidade, "Região"))
                                        } else {
                                            title.trim().to_string()
                                        };

                                        let id = gerar_id(&clean_title, &href);
                                        let trecho = format!("Imóvel particular anunciado na OLX. Anúncio direto de proprietário.");

                                        results.push(SearchResult {
                                            id,
                                            titulo: clean_title,
                                            link: href,
                                            fonte: "olx.com.br (Particular)".to_string(),
                                            trecho,
                                            direto_proprietario: true,
                                            cidade: cidade.clone(),
                                            estado: estado.clone(),
                                            tipo: tipo.clone(),
                                            modalidade: modalidade.clone(),
                                        });
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Ok::<Vec<SearchResult>, Box<dyn std::error::Error>>(results)
        } => r,
        _ = &mut rx => {
            eprintln!("Scraper recebeu sinal de término (SIGTERM/SIGINT). Limpando subprocessos...");
            Err(Box::new(std::io::Error::new(std::io::ErrorKind::Interrupted, "Interrompido por sinal")) as Box<dyn std::error::Error>)
        }
    };

    // 6. Cleanup browser & geckodriver
    let _ = driver.quit().await;
    let _ = geckodriver.kill();

    match res {
        Ok(results) => {
            let json_output = serde_json::to_string_pretty(&results)?;
            println!("{}", json_output);
        }
        Err(e) => {
            eprintln!("Erro ou interrupção no scraper: {}", e);
            std::process::exit(1);
        }
    }

    Ok(())
}

fn se_nao_vazio<'a>(val: &'a str, padrao: &'a str) -> &'a str {
    if val.trim().is_empty() { padrao } else { val }
}
