#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::State;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CidadeAlvo {
    pub estado: String,
    pub cidade: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentConfig {
    pub server_url: String,
    pub polling_schedules: Vec<String>, // Ex: ["08:00", "12:00", "16:00", "20:00"]
    pub cidades_alvo: Option<Vec<CidadeAlvo>>,
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
            polling_schedules: vec![
                "08:00".to_string(),
                "12:00".to_string(),
                "16:00".to_string(),
                "20:00".to_string(),
            ],
            cidades_alvo: Some(vec![
                CidadeAlvo { estado: "CE".to_string(), cidade: "Juazeiro do Norte".to_string() },
                CidadeAlvo { estado: "PE".to_string(), cidade: "Petrolina".to_string() },
                CidadeAlvo { estado: "ES".to_string(), cidade: "São Mateus".to_string() },
                CidadeAlvo { estado: "BA".to_string(), cidade: "Salvador".to_string() },
            ]),
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
    pub target_url: String,
    pub total_encontrados: usize,
    pub novos_encontrados: usize,
    pub removidos_encontrados: usize,
    pub logs: Vec<String>,
    pub message: String,
}

pub struct AppState {
    pub config: Mutex<AgentConfig>,
}

fn normalizar_cidade(cidade: &str) -> String {
    cidade
        .to_lowercase()
        .replace('ã', "a")
        .replace('á', "a")
        .replace('â', "a")
        .replace('é', "e")
        .replace('ê', "e")
        .replace('í', "i")
        .replace('ó', "o")
        .replace('ô', "o")
        .replace('õ', "o")
        .replace('ú', "u")
        .replace('ç', "c")
        .trim()
        .split_whitespace()
        .collect::<Vec<&str>>()
        .join("+")
}

fn md5_hash(input: &str) -> u64 {
    let mut hash: u64 = 5381;
    for byte in input.bytes() {
        hash = ((hash << 5).wrapping_add(hash)).wrapping_add(byte as u64);
    }
    hash
}

fn construir_url_olx(estado: &str, tipo: &str, modalidade: &str, cidade: &str, apenas_particular: bool) -> String {
    let cidade_input = cidade.trim();
    if cidade_input.starts_with("http://") || cidade_input.starts_with("https://") {
        let mut url = cidade_input.to_string();
        if apenas_particular && !url.contains("f=p") {
            let sep = if url.contains('?') { "&" } else { "?" };
            url.push_str(sep);
            url.push_str("f=p");
        }
        return url;
    }

    let clean_uf = estado.to_lowercase().replace("estado-", "");
    let uf_param = if !clean_uf.is_empty() && clean_uf != "br" && clean_uf != "todos" {
        format!("estado-{}", clean_uf)
    } else {
        "".to_string()
    };

    let clean_tipo = match tipo.to_lowercase().as_str() {
        t if t.contains("casa") => "casas",
        t if t.contains("ap") => "apartamentos",
        t if t.contains("terr") || t.contains("lote") => "terrenos-e-lotes",
        t if t.contains("comercial") || t.contains("sala") => "comercio-e-industria",
        _ => "imoveis",
    };

    let clean_mod = if modalidade.to_lowercase() == "aluguel" { "aluguel" } else { "venda" };

    let mut parts = vec!["https://www.olx.com.br/imoveis".to_string(), clean_mod.to_string()];
    if clean_tipo != "imoveis" {
        parts.push(clean_tipo.to_string());
    }
    if !uf_param.is_empty() {
        parts.push(uf_param);
    }

    let mut url = parts.join("/");
    let mut params = Vec::new();
    if apenas_particular {
        params.push("f=p".to_string());
    }
    if !cidade_input.is_empty() {
        let clean_city = normalizar_cidade(cidade_input);
        params.push(format!("q={}", clean_city));
    }

    if !params.is_empty() {
        url.push('?');
        url.push_str(&params.join("&"));
    }

    url
}

async fn raspar_olx(
    estado: &str,
    cidade: &str,
    tipo: &str,
    modalidade: &str,
    logs: &mut Vec<String>,
) -> (Vec<ScrapedItem>, String) {
    let target_url = construir_url_olx(estado, tipo, modalidade, cidade, true);
    logs.push(format!("🔎 [Passo 1] URL Alvo Gerada com Filtro Particular (f=p): {}", target_url));
    logs.push("🌐 [Passo 2] Requisitando anúncios de particulares...".to_string());

    let script_candidates = [
        "scraper_helper.py",
        "src-tauri/scraper_helper.py",
        "desktop-agent/src-tauri/scraper_helper.py",
    ];

    let mut script_file = "scraper_helper.py";
    for cand in script_candidates {
        if std::path::Path::new(cand).exists() {
            script_file = cand;
            break;
        }
    }

    let output = std::process::Command::new("python3")
        .arg(script_file)
        .arg(estado)
        .arg(cidade)
        .arg(tipo)
        .arg(modalidade)
        .output();

    let mut items = Vec::new();
    let mut final_target_url = target_url.clone();

    if let Ok(out) = output {
        let stdout = String::from_utf8_lossy(&out.stdout);
        if let Ok(parsed) = serde_json::from_str::<serde_json::Value>(&stdout) {
            if let Some(t_url) = parsed["target_url"].as_str() {
                final_target_url = t_url.to_string();
            }
            if let Some(arr) = parsed["items"].as_array() {
                for it in arr {
                    items.push(ScrapedItem {
                        id: it["id"].as_str().unwrap_or("").to_string(),
                        titulo: it["titulo"].as_str().unwrap_or("").to_string(),
                        link: it["link"].as_str().unwrap_or("").to_string(),
                        fonte: it["fonte"].as_str().unwrap_or("OLX Particular").to_string(),
                        trecho: it["trecho"].as_str().unwrap_or("").to_string(),
                        direto_proprietario: true,
                    });
                }
            }
            logs.push(format!("✨ Raspagem concluída! Extraídos {} anúncios de imóveis particulares da OLX.", items.len()));
        } else {
            logs.push(format!("⚠️ Resposta inválida: {}", stdout));
        }
    } else {
        logs.push("❌ Não foi possível iniciar o processo de raspagem.".to_string());
    }

    (items, final_target_url)
}

async fn enviar_para_servidor(
    config: &AgentConfig,
    items: Vec<ScrapedItem>,
    target_url: String,
    mut logs: Vec<String>,
) -> Result<SyncResult, String> {
    let base_url = config.server_url.trim_end_matches('/');
    let sync_endpoint = format!("{}/api/prospeccao/sync", base_url);
    let batch_id = format!("desktop-{}", chrono::Utc::now().timestamp());

    logs.push(format!("🚀 Sincronizando lote de {} imóveis com o servidor ({})", items.len(), sync_endpoint));

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
    match client.post(&sync_endpoint).json(&payload).send().await {
        Ok(resp) => {
            if resp.status().is_success() {
                if let Ok(json) = resp.json::<serde_json::Value>().await {
                    let total = json["totalEncontrados"].as_u64().unwrap_or(items.len() as u64) as usize;
                    let novos = json["novosEncontrados"].as_u64().unwrap_or(0) as usize;
                    let removidos = json["removidosEncontrados"].as_u64().unwrap_or(0) as usize;

                    logs.push(format!("📊 Servidor processou com sucesso: Total: {}, Novos ⭐: {}, Desativados ❌: {}.", total, novos, removidos));

                    Ok(SyncResult {
                        success: true,
                        batch_id: batch_id.clone(),
                        target_url,
                        total_encontrados: total,
                        novos_encontrados: novos,
                        removidos_encontrados: removidos,
                        logs,
                        message: format!("Sincronizado com sucesso com {}", config.server_url),
                    })
                } else {
                    logs.push("📊 Sincronizado com sucesso com o servidor!".to_string());
                    Ok(SyncResult {
                        success: true,
                        batch_id,
                        target_url,
                        total_encontrados: items.len(),
                        novos_encontrados: 0,
                        removidos_encontrados: 0,
                        logs,
                        message: "Sincronizado com o servidor.".to_string(),
                    })
                }
            } else {
                let err_msg = format!("Servidor respondeu HTTP {}", resp.status());
                logs.push(format!("❌ Erro no servidor: {}", err_msg));
                Err(err_msg)
            }
        }
        Err(err) => {
            let err_msg = format!("Erro ao conectar com {}: {}", config.server_url, err);
            logs.push(format!("❌ {}", err_msg));
            Err(err_msg)
        }
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
async fn execute_prospeccao_now(
    config: Option<AgentConfig>,
    state: State<'_, AppState>
) -> Result<SyncResult, String> {
    let active_config = match config {
        Some(c) => {
            let mut state_cfg = state.config.lock().unwrap();
            *state_cfg = c.clone();
            c
        }
        None => state.config.lock().unwrap().clone(),
    };

    let mut logs = Vec::new();

    let cidades_para_raspar = match &active_config.cidades_alvo {
        Some(lista) if !lista.is_empty() => lista.clone(),
        _ => vec![CidadeAlvo {
            estado: active_config.estado.clone(),
            cidade: active_config.cidade.clone(),
        }],
    };

    logs.push(format!("🚀 Iniciando varredura em lote para {} cidade(s) alvo salvas...", cidades_para_raspar.len()));

    let mut total_acumulado = 0;
    let mut novos_acumulado = 0;
    let mut removidos_acumulado = 0;
    let mut last_batch_id = format!("desktop-{}", chrono::Utc::now().timestamp());
    let mut last_target_url = "".to_string();

    for (idx, alvo) in cidades_para_raspar.iter().enumerate() {
        logs.push(format!("📍 [{}/{}] Processando Cidade Alvo: {} - {}", idx + 1, cidades_para_raspar.len(), alvo.cidade, alvo.estado));

        let (items, target_url) = raspar_olx(
            &alvo.estado,
            &alvo.cidade,
            &active_config.tipo,
            &active_config.modalidade,
            &mut logs
        ).await;

        last_target_url = target_url.clone();

        let mut config_especifico = active_config.clone();
        config_especifico.estado = alvo.estado.clone();
        config_especifico.cidade = alvo.cidade.clone();

        if let Ok(res) = enviar_para_servidor(&config_especifico, items, target_url, logs.clone()).await {
            total_acumulado += res.total_encontrados;
            novos_acumulado += res.novos_encontrados;
            removidos_acumulado += res.removidos_encontrados;
            last_batch_id = res.batch_id;
        }
    }

    Ok(SyncResult {
        success: true,
        batch_id: last_batch_id,
        target_url: last_target_url,
        total_encontrados: total_acumulado,
        novos_encontrados: novos_acumulado,
        removidos_encontrados: removidos_acumulado,
        logs,
        message: format!("Prospecção concluída para {} cidades com sucesso!", cidades_para_raspar.len()),
    })
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
