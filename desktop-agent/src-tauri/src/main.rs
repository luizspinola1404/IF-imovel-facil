#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::State;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentConfig {
    pub server_url: String,
    pub api_key: String,
    pub polling_schedules: Vec<String>, // Ex: ["08:00", "12:00", "16:00", "20:00"]
    pub estado: String,
    pub cidade: String,
    pub tipo: String,
    pub modalidade: String,
    pub auto_polling_enabled: bool,
}

impl Default for AgentConfig {
    fn default() -> Self {
        Self {
            server_url: "https://luizspinolaimoveis.com.br".to_string(),
            api_key: "".to_string(),
            polling_schedules: vec![
                "08:00".to_string(),
                "12:00".to_string(),
                "16:00".to_string(),
                "20:00".to_string(),
            ],
            estado: "ES".to_string(),
            cidade: "São Mateus".to_string(),
            tipo: "Casa".to_string(),
            modalidade: "venda".to_string(),
            auto_polling_enabled: true,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScrapedItem {
    pub id: String,
    pub titulo: String,
    pub link: String,
    pub fonte: String,
    pub trecho: String,
    pub direto_proprietario: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncResult {
    pub success: bool,
    pub batch_id: String,
    pub total_encontrados: usize,
    pub novos_encontrados: usize,
    pub removidos_encontrados: usize,
    pub message: String,
}

pub struct AppState {
    pub config: Mutex<AgentConfig>,
}

fn normalizar_cidade(cidade: &str) -> String {
    cidade
        .to_lowercase()
        .replace("ã", "a")
        .replace("á", "a")
        .replace("â", "a")
        .replace("é", "e")
        .replace("ê", "e")
        .replace("í", "i")
        .replace("ó", "o")
        .replace("ô", "o")
        .replace("õ", "o")
        .replace("ú", "u")
        .replace("ç", "c")
        .trim()
        .split_whitespace()
        .collect::<Vec<&str>>()
        .join("+")
}

async fn raspar_olx(estado: &str, cidade: &str, tipo: &str, modalidade: &str) -> Vec<ScrapedItem> {
    let clean_uf = estado.to_lowercase();
    let clean_city = normalizar_cidade(cidade);
    let clean_tipo = match tipo.to_lowercase().as_str() {
        t if t.contains("casa") => "casas",
        t if t.contains("ap") => "apartamentos",
        t if t.contains("terr") || t.contains("lote") => "terrenos-e-lotes",
        _ => "imoveis",
    };
    let clean_mod = if modalidade.to_lowercase() == "aluguel" { "aluguel" } else { "venda" };

    let url = format!(
        "https://www.olx.com.br/imoveis/{}/{}/estado-{}?f=p&q={}",
        clean_mod, clean_tipo, clean_uf, clean_city
    );

    let client = reqwest::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36")
        .build();

    let mut items = Vec::new();
    if let Ok(client) = client {
        if let Ok(resp) = client.get(&url).send().await {
            if let Ok(html) = resp.text().await {
                let document = scraper::Html::parse_document(&html);
                let selector = scraper::Selector::parse("a[href]").unwrap();

                let mut seen = std::collections::HashSet::new();
                for element in document.select(&selector) {
                    if let Some(href) = element.value().attr("href") {
                        if href.contains("olx.com.br") && href.contains("/imoveis/") && href.contains("-") {
                            if !seen.contains(href) {
                                seen.insert(href.to_string());
                                let full_link = if href.starts_with("http") {
                                    href.to_string()
                                } else {
                                    format!("https://www.olx.com.br{}", href)
                                };

                                let title_text = element.text().collect::<String>().trim().to_string();
                                let title = if title_text.len() > 5 {
                                    title_text
                                } else {
                                    format!("Imóvel Direto com Proprietário em {}-{}", cidade, estado)
                                };

                                let raw_id = format!("{}{}", title, full_link);
                                let id = format!("{:x}", md5_hash(&raw_id));

                                items.push(ScrapedItem {
                                    id,
                                    titulo: title,
                                    link: full_link,
                                    fonte: "OLX Brasil (Particular)".to_string(),
                                    trecho: format!("Imóvel de proprietário particular capturado em {}-{}.", cidade, estado),
                                    direto_proprietario: true,
                                });
                            }
                        }
                    }
                }
            }
        }
    }
    items
}

fn md5_hash(input: &str) -> u64 {
    let mut hash: u64 = 5381;
    for byte in input.bytes() {
        hash = ((hash << 5).wrapping_add(hash)).wrapping_add(byte as u64);
    }
    hash
}

async fn enviar_para_servidor(config: &AgentConfig, items: Vec<ScrapedItem>) -> Result<SyncResult, String> {
    let base_url = config.server_url.trim_end_matches('/');
    let sync_endpoint = format!("{}/api/prospeccao/sync", base_url);

    let batch_id = format!("desktop-{}", chrono::Utc::now().timestamp());

    let payload = serde_json::json!({
        "batchId": batch_id,
        "fonte": "olx.com.br",
        "estado": config.estado,
        "cidade": config.cidade,
        "tipo": config.tipo,
        "modalidade": config.modalidade,
        "items": items
    });

    let client = reqwest::Client::new();
    let mut req = client.post(&sync_endpoint).json(&payload);

    if !config.api_key.is_empty() {
        req = req.header("Authorization", format!("Bearer {}", config.api_key));
    }

    match req.send().await {
        Ok(resp) => {
            if resp.status().is_success() {
                if let Ok(json) = resp.json::<serde_json::Value>().await {
                    Ok(SyncResult {
                        success: true,
                        batch_id: batch_id.clone(),
                        total_encontrados: json["totalEncontrados"].as_u64().unwrap_or(0) as usize,
                        novos_encontrados: json["novosEncontrados"].as_u64().unwrap_or(0) as usize,
                        removidos_encontrados: json["removidosEncontrados"].as_u64().unwrap_or(0) as usize,
                        message: format!("Sincronizado com sucesso com {}", config.server_url),
                    })
                } else {
                    Ok(SyncResult {
                        success: true,
                        batch_id,
                        total_encontrados: items.len(),
                        novos_encontrados: 0,
                        removidos_encontrados: 0,
                        message: "Sincronizado com o servidor.".to_string(),
                    })
                }
            } else {
                Err(format!("Servidor respondeu com código de erro HTTP {}", resp.status()))
            }
        }
        Err(err) => Err(format!("Falha de conexão com o servidor {}: {}", config.server_url, err)),
    }
}

#[tauri::command]
fn get_config(state: State<'_, AppState>) -> AgentConfig {
    state.config.lock().unwrap().clone()
}

#[tauri::command]
fn save_config(config: AgentConfig, state: State<'_, AppState>) -> Result<String, String> {
    let mut cfg = state.config.lock().unwrap();
    *cfg = config;
    Ok("Configurações salvas com sucesso!".to_string())
}

#[tauri::command]
async fn execute_prospeccao_now(state: State<'_, AppState>) -> Result<SyncResult, String> {
    let cfg = state.config.lock().unwrap().clone();
    let items = raspar_olx(&cfg.estado, &cfg.cidade, &cfg.tipo, &cfg.modalidade).await;
    enviar_para_servidor(&cfg, items).await
}

fn main() {
    tauri::Builder::default()
        .manage(AppState {
            config: Mutex::new(AgentConfig::default()),
        })
        .invoke_handler(tauri::generate_handler![
            get_config,
            save_config,
            execute_prospeccao_now
        ])
        .run(tauri::generate_context!())
        .expect("erro ao rodar o agente tauri");
}
