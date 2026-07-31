#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::{Emitter, State};

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
    #[serde(default)]
    pub tipo: String,
    #[serde(default)]
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
            cidades_alvo: Some(vec![]),
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

fn timestamp_atual() -> String {
    chrono::Local::now().format("%H:%M:%S").to_string()
}

async fn fetch_html_rust(client: &reqwest::Client, url: &str) -> Result<(u16, String), String> {
    let req_builder = client
        .get(url)
        .timeout(std::time::Duration::from_secs(10))
        .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36")
        .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8")
        .header("Accept-Language", "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7")
        .header("Sec-Ch-Ua", "\"Google Chrome\";v=\"123\", \"Not:A-Brand\";v=\"8\", \"Chromium\";v=\"123\"")
        .header("Sec-Ch-Ua-Mobile", "?0")
        .header("Sec-Ch-Ua-Platform", "\"Windows\"")
        .header("Sec-Fetch-Dest", "document")
        .header("Sec-Fetch-Mode", "navigate")
        .header("Sec-Fetch-Site", "none")
        .header("Sec-Fetch-User", "?1")
        .header("Upgrade-Insecure-Requests", "1");

    match req_builder.send().await {
        Ok(resp) => {
            let status = resp.status().as_u16();
            let text = resp.text().await.map_err(|e| e.to_string())?;
            Ok((status, text))
        }
        Err(err) => Err(format!("Timeout/Erro de rede ({})", err)),
    }
}

fn registrar_log(app: &tauri::AppHandle, logs: &mut Vec<String>, msg: String) {
    println!("LOG EMITIDO: {}", msg);
    logs.push(msg.clone());
    if let Err(e) = app.emit("prospeccao_log", msg) {
        println!("ERRO CRÍTICO AO EMITIR LOG PARA A TELA: {:?}", e);
    }
}

async fn raspar_olx(
    app: &tauri::AppHandle,
    estado: &str,
    cidade: &str,
    tipo: &str,
    modalidade: &str,
    logs: &mut Vec<String>,
) -> (Vec<ScrapedItem>, String) {
    let target_url = construir_url_olx(estado, tipo, modalidade, cidade, true);
    registrar_log(app, logs, format!("[{}] ⚡ Buscando {} ({}) em {}-{} (Motor Nativo Rust)...", timestamp_atual(), tipo, modalidade, cidade, estado));

    let client = reqwest::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36")
        .build()
        .unwrap_or_else(|_| reqwest::Client::new());

    // Tentar raspagem nativa Rust primeiro
    match fetch_html_rust(&client, &target_url).await {
        Ok((200, html)) => {
            let mut items = Vec::new();
            let mut seen = std::collections::HashSet::new();

            if let Ok(re) = regex::Regex::new(r#"href="(https://[a-z0-9\.-]*olx\.com\.br/[^"]*?-\d+)""#) {
                for cap in re.captures_iter(&html) {
                    if let Some(link_match) = cap.get(1) {
                        let link = link_match.as_str().to_string();
                        if !seen.contains(&link) && !link.ends_with(".png") && !link.ends_with(".jpg") {
                            seen.insert(link.clone());

                            let slug = link.split('/').last().unwrap_or("").to_string();
                            let raw_title = slug.rsplit_once('-')
                                .map(|(t, _)| t.replace('-', " "))
                                .unwrap_or_else(|| format!("Imóvel Particular em {}-{}", cidade, estado));

                            let titulo = raw_title.chars().enumerate().map(|(i, c)| {
                                if i == 0 || raw_title.chars().nth(i.saturating_sub(1)).map_or(false, |p| p == ' ') {
                                    c.to_uppercase().next().unwrap_or(c)
                                } else {
                                    c
                                }
                            }).collect::<String>();

                            let id = format!("olx-{}", slug);

                            items.push(ScrapedItem {
                                id,
                                titulo,
                                link,
                                fonte: "OLX Brasil (Particular)".to_string(),
                                trecho: format!("Imóvel de proprietário particular capturado em {}-{}.", cidade, estado),
                                direto_proprietario: true,
                            });
                        }
                    }
                }
            }

            if !items.is_empty() {
                registrar_log(app, logs, format!("[{}] ✅ Extração nativa concluída! {} imóveis capturados em {}-{}.", timestamp_atual(), items.len(), cidade, estado));
                return (items, target_url);
            }
        }
        _ => {}
    }

    // Fallback: Tentar script Python local caso a raspagem nativa Rust não encontre resultados
    let script_file = if std::path::Path::new("scraper_helper.py").exists() {
        "scraper_helper.py"
    } else if std::path::Path::new("src-tauri/scraper_helper.py").exists() {
        "src-tauri/scraper_helper.py"
    } else {
        "desktop-agent/src-tauri/scraper_helper.py"
    };

    let output = tokio::process::Command::new("python3")
        .arg(script_file)
        .arg(estado)
        .arg(cidade)
        .arg(tipo)
        .arg(modalidade)
        .output()
        .await;

    let mut items = Vec::new();
    let mut final_url = target_url;

    if let Ok(out) = output {
        let stdout = String::from_utf8_lossy(&out.stdout);
        if let Ok(parsed) = serde_json::from_str::<serde_json::Value>(&stdout) {
            if let Some(u) = parsed["target_url"].as_str() {
                final_url = u.to_string();
            }
            if let Some(arr) = parsed["items"].as_array() {
                for it in arr {
                    items.push(ScrapedItem {
                        id: it["id"].as_str().unwrap_or("").to_string(),
                        titulo: it["titulo"].as_str().unwrap_or("").to_string(),
                        link: it["link"].as_str().unwrap_or("").to_string(),
                        fonte: it["fonte"].as_str().unwrap_or("OLX Brasil (Particular)").to_string(),
                        trecho: it["trecho"].as_str().unwrap_or("").to_string(),
                        direto_proprietario: true,
                    });
                }
            }
            registrar_log(app, logs, format!("[{}] ✅ Extração concluída! {} imóveis capturados em {}-{}.", timestamp_atual(), items.len(), cidade, estado));
        } else {
            registrar_log(app, logs, format!("[{}] ⚠️ Resposta do script Python foi inválida.", timestamp_atual()));
        }
    } else {
        registrar_log(app, logs, format!("[{}] ⚠️ Raspagem finalizada com 0 imóveis para o filtro atual.", timestamp_atual()));
    }

    (items, final_url)
}

async fn enviar_para_servidor(
    app: &tauri::AppHandle,
    config: &AgentConfig,
    items: Vec<ScrapedItem>,
    target_url: String,
    mut logs: Vec<String>,
) -> Result<SyncResult, String> {
    let base_url = config.server_url.trim_end_matches('/');
    let sync_endpoint = format!("{}/api/prospeccao/sync", base_url);
    let batch_id = format!("desktop-{}", chrono::Utc::now().timestamp());

    registrar_log(app, &mut logs, format!("[{}] 🚀 Sincronizando lote de {} imóveis com o servidor ({})", timestamp_atual(), items.len(), sync_endpoint));

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
    match client.post(&sync_endpoint).timeout(std::time::Duration::from_secs(5)).json(&payload).send().await {
        Ok(resp) => {
            if resp.status().is_success() {
                if let Ok(json) = resp.json::<serde_json::Value>().await {
                    let total = json["totalEncontrados"].as_u64().unwrap_or(items.len() as u64) as usize;
                    let novos = json["novosEncontrados"].as_u64().unwrap_or(0) as usize;
                    let removidos = json["removidosEncontrados"].as_u64().unwrap_or(0) as usize;

                    registrar_log(app, &mut logs, format!("[{}] 📊 Servidor processou com sucesso: Total: {}, Novos ⭐: {}, Desativados ❌: {}.", timestamp_atual(), total, novos, removidos));

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
                    registrar_log(app, &mut logs, format!("[{}] 📊 Sincronizado com sucesso com o servidor!", timestamp_atual()));
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
                registrar_log(app, &mut logs, format!("[{}] ❌ Erro no servidor: {}", timestamp_atual(), err_msg));
                Err(err_msg)
            }
        }
        Err(err) => {
            let err_msg = format!("Erro ao conectar com {}: {}", config.server_url, err);
            registrar_log(app, &mut logs, format!("[{}] ❌ {}", timestamp_atual(), err_msg));
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
    app: tauri::AppHandle,
    config: Option<AgentConfig>,
    state: State<'_, AppState>
) -> Result<SyncResult, String> {
    println!("DEBUG: execute_prospeccao_now iniciado! Recebido config={:?}", config);

    let active_config = match config {
        Some(c) => {
            println!("DEBUG: Atualizando state.config com o config recebido.");
            let mut state_cfg = state.config.lock().unwrap();
            *state_cfg = c.clone();
            c
        }
        None => {
            println!("DEBUG: Usando state.config existente.");
            state.config.lock().unwrap().clone()
        }
    };

    println!("DEBUG: Configuração ativa definida: {:?}", active_config);
    let mut logs = Vec::new();

    let cidades_para_raspar = match &active_config.cidades_alvo {
        Some(lista) if !lista.is_empty() => lista.clone(),
        _ => vec![CidadeAlvo {
            estado: active_config.estado.clone(),
            cidade: active_config.cidade.clone(),
        }],
    };

    let tipos = vec!["Casa", "Apartamento", "Terreno", "Comercial"];
    let modalidades = vec!["venda", "aluguel"];

    let total_combinacoes = cidades_para_raspar.len() * tipos.len() * modalidades.len();
    println!("DEBUG: Cidades alvo = {}, total_combinacoes = {}", cidades_para_raspar.len(), total_combinacoes);
    println!("DEBUG: Chamando registrar_log pela 1a vez...");
    registrar_log(&app, &mut logs, format!("[{}] 🚀 Iniciando varredura em lote ({} cidades × {} tipos × {} modalidades = {} sub-tarefas)...", timestamp_atual(), cidades_para_raspar.len(), tipos.len(), modalidades.len(), total_combinacoes));
    println!("DEBUG: Voltou do registrar_log com sucesso!");

    let mut total_acumulado = 0;
    let mut novos_acumulado = 0;
    let mut removidos_acumulado = 0;
    let mut last_batch_id = format!("desktop-{}", chrono::Utc::now().timestamp());
    let mut last_target_url = "".to_string();
    let mut passo_atual = 1;

    for alvo in cidades_para_raspar.iter() {
        registrar_log(&app, &mut logs, format!("[{}] 📍 Iniciando varredura para a Cidade Alvo: {} - {}", timestamp_atual(), alvo.cidade, alvo.estado));

        for tipo in &tipos {
            for modalidade in &modalidades {
                registrar_log(&app, &mut logs, format!("[{}] 🔄 [{}/{}] Processando {} para {} em {}...", timestamp_atual(), passo_atual, total_combinacoes, tipo, modalidade, alvo.cidade));

                let (items, target_url) = raspar_olx(
                    &app,
                    &alvo.estado,
                    &alvo.cidade,
                    tipo,
                    modalidade,
                    &mut logs
                ).await;

                last_target_url = target_url.clone();

                let mut config_especifico = active_config.clone();
                config_especifico.estado = alvo.estado.clone();
                config_especifico.cidade = alvo.cidade.clone();
                config_especifico.tipo = tipo.to_string();
                config_especifico.modalidade = modalidade.to_string();

                if let Ok(res) = enviar_para_servidor(&app, &config_especifico, items, target_url, logs.clone()).await {
                    total_acumulado += res.total_encontrados;
                    novos_acumulado += res.novos_encontrados;
                    removidos_acumulado += res.removidos_encontrados;
                    last_batch_id = res.batch_id;
                }
                
                // Intervalo de segurança amigável para evitar rate-limit da Cloudflare
                if passo_atual < total_combinacoes {
                    let delay_secs = 5 + (passo_atual % 4); // Alterna entre 5 e 8 segundos
                    registrar_log(&app, &mut logs, format!("[{}] ⏳ Aguardando {}s para a próxima consulta (respeitando limites da OLX)...", timestamp_atual(), delay_secs));
                    tokio::time::sleep(std::time::Duration::from_secs(delay_secs as u64)).await;
                }

                passo_atual += 1;
            }
        }
    }

    registrar_log(&app, &mut logs, format!("[{}] 🎉 Varredura completa finalizada!", timestamp_atual()));

    Ok(SyncResult {
        success: true,
        batch_id: last_batch_id,
        target_url: last_target_url,
        total_encontrados: total_acumulado,
        novos_encontrados: novos_acumulado,
        removidos_encontrados: removidos_acumulado,
        logs,
        message: format!("Prospecção concluída para {} cidades e todas as combinações!", cidades_para_raspar.len()),
    })
}

use tauri::{
    menu::{Menu, MenuItem},
    tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
    Manager, WindowEvent,
};

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
        .setup(|app| {
            // Cria o menu do Tray
            let quit_i = MenuItem::with_id(app, "quit", "Sair", true, None::<&str>)?;
            let show_i = MenuItem::with_id(app, "show", "Mostrar", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&show_i, &quit_i])?;

            // Constrói o ícone do Tray
            let _tray = TrayIconBuilder::new()
                .icon(app.default_window_icon().unwrap().clone())
                .menu(&menu)
                .on_menu_event(|app, event| match event.id.as_ref() {
                    "quit" => {
                        std::process::exit(0);
                    }
                    "show" => {
                        if let Some(window) = app.get_webview_window("main") {
                            window.show().unwrap();
                            window.set_focus().unwrap();
                        }
                    }
                    _ => {}
                })
                .on_tray_icon_event(|tray, event| {
                    // Restaura a janela se clicar com o botão esquerdo
                    if let TrayIconEvent::Click {
                        button: MouseButton::Left,
                        button_state: MouseButtonState::Up,
                        ..
                    } = event
                    {
                        if let Some(window) = tray.app_handle().get_webview_window("main") {
                            window.show().unwrap();
                            window.set_focus().unwrap();
                        }
                    }
                })
                .build(app)?;

            Ok(())
        })
        .on_window_event(|window, event| match event {
            // Ao invés de fechar, esconde para o Tray
            WindowEvent::CloseRequested { api, .. } => {
                window.hide().unwrap();
                api.prevent_close();
            }
            _ => {}
        })
        .run(tauri::generate_context!())
        .expect("erro ao rodar o agente tauri");
}
