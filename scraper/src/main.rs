use thirtyfour::prelude::*;
use serde::{Serialize, Deserialize};
use std::process::Command;
use std::thread;
use std::time::Duration;

#[derive(Serialize, Deserialize, Debug)]
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

const DIRETO_KEYWORDS: &[&str] = &[
    "direto proprietário",
    "direto com proprietário",
    "direto do proprietário",
    "direto proprietario",
    "direto com proprietario",
    "direto do proprietario",
    "particular",
    "sem corretor",
    "proprietário vende",
    "proprietário aluga",
    "proprietario vende",
    "proprietario aluga",
    "dono vende",
    "dono aluga",
    "vendo direto",
    "alugo direto",
    "sem imobiliária",
    "sem imobiliaria",
];

fn classificar_direto(texto: &str) -> bool {
    let lower = texto.to_lowercase();
    DIRETO_KEYWORDS.iter().any(|&kw| lower.contains(kw))
}

fn extrair_fonte(url_str: &str) -> String {
    let clean = url_str.replace("https://", "").replace("http://", "");
    let parts: Vec<&str> = clean.split('/').collect();
    if !parts.is_empty() {
        parts[0].replace("www.", "")
    } else {
        "Web".to_string()
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
    let mut cidade = String::new();
    let mut estado = String::new();
    let mut tipo = String::new();
    let mut modalidade = String::new();

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
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

    if cidade.is_empty() || estado.is_empty() || tipo.is_empty() || modalidade.is_empty() {
        eprintln!("Erro: argumentos faltando. Uso: scraper --cidade <cidade> --estado <estado> --tipo <tipo> --modalidade <modalidade>");
        std::process::exit(1);
    }

    // 2. Start Geckodriver in the background on a dynamic port based on PID to prevent conflicts
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

    // Wait a brief moment for geckodriver to boot up
    thread::sleep(Duration::from_millis(1500));

    // 3. Setup thirtyfour Webdriver capabilities
    let mut caps = DesiredCapabilities::firefox();
    caps.add_arg("--headless")?;

    let driver_url = format!("http://localhost:{}", port);
    let driver = match WebDriver::new(&driver_url, caps).await {
        Ok(d) => d,
        Err(e) => {
            let _ = geckodriver.kill();
            eprintln!("Erro ao conectar com o WebDriver: {}", e);
            std::process::exit(1);
        }
    };

    // 4. Construct query and execute search on standard DuckDuckGo
    let query_term = format!(
        "{} {} {} {} direto proprietario OR particular OR sem corretor",
        tipo, modalidade, cidade, estado
    );
    let search_url = format!(
        "https://duckduckgo.com/?q={}",
        urlencoding::encode(&query_term)
    );

    let mut results: Vec<SearchResult> = Vec::new();

    if let Err(e) = driver.goto(&search_url).await {
        eprintln!("Erro ao navegar até o buscador: {}", e);
    } else {
        // Wait for results to render
        thread::sleep(Duration::from_millis(4000));

        // Find result rows using modern data-testid attributes
        if let Ok(elements) = driver.find_all(By::Css("[data-testid=\"result\"]")).await {
            for el in elements {
                if let Ok(title_el) = el.find(By::Css("[data-testid=\"result-title-a\"]")).await {
                    if let (Ok(title), Ok(Some(link))) = (title_el.text().await, title_el.attr("href").await) {
                        // Ignore internal links
                        if link.contains("duckduckgo.com/") || link.starts_with('/') {
                            continue;
                        }

                        let snippet = match el.find(By::Css("[data-testid=\"result-snippet\"]")).await {
                            Ok(snippet_el) => snippet_el.text().await.unwrap_or_default(),
                            Err(_) => String::new(),
                        };

                        let is_direct = classificar_direto(&title) || classificar_direto(&snippet);
                        let source = extrair_fonte(&link);
                        let id = gerar_id(&title, &link);

                        results.push(SearchResult {
                            id,
                            titulo: title,
                            link,
                            fonte: source,
                            trecho: snippet,
                            direto_proprietario: is_direct,
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

    // 5. Cleanup browser & geckodriver
    let _ = driver.quit().await;
    let _ = geckodriver.kill();

    // 6. Output findings as JSON to stdout
    let json_output = serde_json::to_string_pretty(&results)?;
    println!("{}", json_output);

    Ok(())
}
