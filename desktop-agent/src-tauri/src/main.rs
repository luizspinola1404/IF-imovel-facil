#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::{Emitter, State};
use headless_chrome::{Browser, LaunchOptionsBuilder};

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
    #[serde(default = "default_headless")]
    pub headless: bool,
}

fn default_headless() -> bool {
    true
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
            headless: true,
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

fn mapa_tipo_slug(tipo: &str) -> String {
    match tipo.to_lowercase().trim() {
        "casa" | "casas" => "casas".to_string(),
        "apartamento" | "apartamentos" => "apartamentos".to_string(),
        "terreno" | "terrenos" | "lote" | "lotes" => "terrenos-e-lotes".to_string(),
        "comercial" | "sala" | "galpao" => "comercio-e-industria".to_string(),
        "imoveis" => "imoveis".to_string(),
        "todos" => "".to_string(),
        other => other.to_string(),
    }
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

    let st = estado.to_lowercase().replace("estado-", "").trim().to_string();
    let uf_param = if !st.is_empty() && st != "br" && st != "todos" && st != "all" {
        format!("estado-{}", st)
    } else {
        "".to_string()
    };

    let tipo_slug = mapa_tipo_slug(tipo);
    let mod_slug = modalidade.to_lowercase().trim().to_string();

    let mut parts = vec!["https://www.olx.com.br/imoveis".to_string(), mod_slug];
    if !tipo_slug.is_empty() && tipo_slug != "imoveis" {
        parts.push(tipo_slug);
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
    headless: bool,
) -> (Vec<ScrapedItem>, String) {
    let mut target_url = construir_url_olx(estado, tipo, modalidade, cidade, true);
    if !target_url.contains("f=p") {
        let sep = if target_url.contains('?') { "&" } else { "?" };
        target_url.push_str(&format!("{}f=p", sep));
    }

    registrar_log(app, logs, format!("[{}] ⚡ Conectando ao Google Chrome em {}-{} ({}/{})...", timestamp_atual(), cidade, estado, tipo, modalidade));

    let args: Vec<&std::ffi::OsStr> = vec![
        std::ffi::OsStr::new("--disable-blink-features=AutomationControlled"),
        std::ffi::OsStr::new("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"),
        std::ffi::OsStr::new("--no-sandbox"),
        std::ffi::OsStr::new("--disable-setuid-sandbox"),
    ];

    let options = match LaunchOptionsBuilder::default()
        .headless(headless)
        .args(args)
        .build() {
            Ok(o) => o,
            Err(e) => {
                registrar_log(app, logs, format!("[{}] ❌ Erro ao configurar Chrome: {}", timestamp_atual(), e));
                return (vec![], target_url);
            }
        };

    let browser = match Browser::new(options) {
        Ok(b) => b,
        Err(e) => {
            registrar_log(app, logs, format!("[{}] ❌ Erro ao abrir Google Chrome: {}", timestamp_atual(), e));
            return (vec![], target_url);
        }
    };

    let tab = match browser.new_tab() {
        Ok(t) => t,
        Err(e) => {
            registrar_log(app, logs, format!("[{}] ❌ Erro ao abrir aba no Chrome: {}", timestamp_atual(), e));
            return (vec![], target_url);
        }
    };

    registrar_log(app, logs, format!("[{}] 🌐 Acessando URL: {}", timestamp_atual(), target_url));
    if let Err(e) = tab.navigate_to(&target_url) {
        registrar_log(app, logs, format!("[{}] ❌ Erro ao navegar para a URL: {}", timestamp_atual(), e));
        return (vec![], target_url);
    }

    registrar_log(app, logs, format!("[{}] ⏳ Aguardando carregamento dos imóveis...", timestamp_atual()));
    let _ = tab.wait_until_navigated();
    tokio::time::sleep(std::time::Duration::from_secs(4)).await;

    let html_inicial = match tab.get_content() {
        Ok(c) => c,
        Err(e) => {
            registrar_log(app, logs, format!("[{}] ❌ Erro ao ler conteúdo da página: {}", timestamp_atual(), e));
            return (vec![], target_url);
        }
    };

    let mut total_imoveis = 0;
    if let Ok(re_tot) = regex::Regex::new(r#"(?i)(?:de\s+)?([\d\.]+)\s+resultados"#) {
        if let Some(cap) = re_tot.captures(&html_inicial) {
            if let Some(m) = cap.get(1) {
                let num_str = m.as_str().replace('.', "");
                total_imoveis = num_str.parse::<usize>().unwrap_or(0);
            }
        }
    }

    let total_paginas = if total_imoveis > 0 { (total_imoveis as f64 / 50.0).ceil() as usize } else { 1 };
    let max_paginas = if total_imoveis == 0 { 1 } else { std::cmp::min(total_paginas, 3) };

    registrar_log(app, logs, format!("[{}] 📊 Total de imóveis detectados: {} (varrendo {} páginas)...", timestamp_atual(), total_imoveis, max_paginas));

    let mut todos_os_items = Vec::new();
    let mut seen = std::collections::HashSet::new();

    let re_href = regex::Regex::new(r#"href="(https://[a-z0-9\.-]*olx\.com\.br/[^"]*?-\d+)""#).unwrap();
    let re_all = regex::Regex::new(r#"https://[a-z0-9\.-]*olx\.com\.br/[^"'\s\?]*?-\d+"#).unwrap();

    for pagina in 1..=max_paginas {
        let html_pagina = if pagina == 1 {
            html_inicial.clone()
        } else {
            let sep = if target_url.contains('?') { "&" } else { "?" };
            let url_pag = format!("{}{:?}o={}", target_url, sep, pagina);
            registrar_log(app, logs, format!("[{}] 🔄 Lendo página {}/{}...", timestamp_atual(), pagina, max_paginas));
            if let Ok(_) = tab.navigate_to(&url_pag) {
                let _ = tab.wait_until_navigated();
                tokio::time::sleep(std::time::Duration::from_secs(3)).await;
                tab.get_content().unwrap_or_default()
            } else {
                break;
            }
        };

        let mut matches = Vec::new();
        for cap in re_href.captures_iter(&html_pagina) {
            if let Some(m) = cap.get(1) {
                matches.push(m.as_str().to_string());
            }
        }
        if matches.is_empty() {
            for cap in re_all.captures_iter(&html_pagina) {
                if let Some(m) = cap.get(0) {
                    matches.push(m.as_str().to_string());
                }
            }
        }

        let mut novos_na_pagina = 0;
        for link in matches {
            if !seen.contains(&link) && !link.ends_with(".png") && !link.ends_with(".jpg") && !link.ends_with(".ico") {
                seen.insert(link.clone());
                novos_na_pagina += 1;

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

                todos_os_items.push(ScrapedItem {
                    id,
                    titulo,
                    link,
                    fonte: "OLX Brasil (Particular)".to_string(),
                    trecho: format!("Imóvel de proprietário particular capturado em {}-{}.", cidade, estado),
                    direto_proprietario: true,
                });
            }
        }

        if novos_na_pagina == 0 {
            break;
        }
    }

    if todos_os_items.is_empty() {
        registrar_log(app, logs, format!("[{}] ⚠️ Raspagem finalizada com 0 imóveis para este filtro.", timestamp_atual()));
    } else {
        registrar_log(app, logs, format!("[{}] ✅ Extração concluída! {} imóveis capturados com sucesso.", timestamp_atual(), todos_os_items.len()));
    }

    (todos_os_items, target_url)
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

#[derive(Debug, Serialize, Deserialize)]
pub struct ServerConfigResponse {
    pub cidades: Option<Vec<CidadeAlvo>>,
    pub polling_schedules: Option<Vec<String>>,
    pub auto_polling_enabled: Option<bool>,
}

#[tauri::command]
async fn fetch_server_config(server_url: String, state: State<'_, AppState>) -> Result<ServerConfigResponse, String> {
    let base_url = server_url.trim_end_matches('/');
    let endpoint = format!("{}/api/prospeccao/cidades-alvo", base_url);
    println!("DEBUG: Buscando configurações nativas do servidor: {}", endpoint);

    let client = reqwest::Client::new();
    match client.get(&endpoint).timeout(std::time::Duration::from_secs(5)).send().await {
        Ok(resp) => {
            let status = resp.status();
            if status.is_success() {
                if let Ok(data) = resp.json::<ServerConfigResponse>().await {
                    println!("DEBUG: Configurações recebidas do servidor via Rust nativo: {:?}", data);
                    let mut cfg = state.config.lock().unwrap();
                    if let Some(ref list) = data.cidades {
                        cfg.cidades_alvo = Some(list.clone());
                    }
                    if let Some(ref scheds) = data.polling_schedules {
                        cfg.polling_schedules = scheds.clone();
                    }
                    if let Some(auto) = data.auto_polling_enabled {
                        cfg.auto_polling_enabled = auto;
                    }
                    return Ok(data);
                }
            }
            Err(format!("Servidor respondeu HTTP {}", status))
        }
        Err(e) => Err(format!("Erro de conexão nativa: {}", e)),
    }
}

#[tauri::command]
async fn sync_server_config(server_url: String, config: AgentConfig, state: State<'_, AppState>) -> Result<String, String> {
    let base_url = server_url.trim_end_matches('/');
    let endpoint = format!("{}/api/prospeccao/cidades-alvo", base_url);
    println!("DEBUG: Sincronizando configurações nativas com o servidor: {}", endpoint);

    {
        let mut cfg = state.config.lock().unwrap();
        *cfg = config.clone();
    }

    let payload = serde_json::json!({
        "cidades": config.cidades_alvo.unwrap_or_default(),
        "polling_schedules": config.polling_schedules,
        "auto_polling_enabled": config.auto_polling_enabled
    });

    let client = reqwest::Client::new();
    match client.post(&endpoint).timeout(std::time::Duration::from_secs(5)).json(&payload).send().await {
        Ok(resp) => {
            if resp.status().is_success() {
                Ok("Sincronizado com sucesso!".to_string())
            } else {
                Err(format!("Servidor respondeu HTTP {}", resp.status()))
            }
        }
        Err(e) => Err(format!("Erro ao sincronizar com servidor: {}", e)),
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

    let app_clone = app.clone();
    tauri::async_runtime::spawn(async move {
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
        registrar_log(&app_clone, &mut logs, format!("[{}] 🚀 Iniciando varredura em lote ({} cidades × {} tipos × {} modalidades = {} sub-tarefas)...", timestamp_atual(), cidades_para_raspar.len(), tipos.len(), modalidades.len(), total_combinacoes));

        let mut _total_acumulado = 0;
        let mut novos_acumulado = 0;
        let mut removidos_acumulado = 0;
        let mut _last_batch_id = format!("desktop-{}", chrono::Utc::now().timestamp());
        let mut _last_target_url = "".to_string();
        let mut passo_atual = 1;

        for alvo in cidades_para_raspar.iter() {
            registrar_log(&app_clone, &mut logs, format!("[{}] 📍 Iniciando varredura para a Cidade Alvo: {} - {}", timestamp_atual(), alvo.cidade, alvo.estado));

            for tipo in &tipos {
                for modalidade in &modalidades {
                    registrar_log(&app_clone, &mut logs, format!("[{}] 🔄 [{}/{}] Processando {} para {} em {}...", timestamp_atual(), passo_atual, total_combinacoes, tipo, modalidade, alvo.cidade));

                    let (items, target_url) = raspar_olx(
                        &app_clone,
                        &alvo.estado,
                        &alvo.cidade,
                        tipo,
                        modalidade,
                        &mut logs,
                        active_config.headless
                    ).await;

                    _last_target_url = target_url.clone();

                    let mut config_especifico = active_config.clone();
                    config_especifico.estado = alvo.estado.clone();
                    config_especifico.cidade = alvo.cidade.clone();
                    config_especifico.tipo = tipo.to_string();
                    config_especifico.modalidade = modalidade.to_string();

                    if let Ok(res) = enviar_para_servidor(&app_clone, &config_especifico, items, target_url, logs.clone()).await {
                        _total_acumulado += res.total_encontrados;
                        novos_acumulado += res.novos_encontrados;
                        removidos_acumulado += res.removidos_encontrados;
                        _last_batch_id = res.batch_id;
                    }
                    
                    // Intervalo de segurança amigável para evitar rate-limit da Cloudflare
                    if passo_atual < total_combinacoes {
                        let delay_secs = 5 + (passo_atual % 4); // Alterna entre 5 e 8 segundos
                        registrar_log(&app_clone, &mut logs, format!("[{}] ⏳ Aguardando {}s para a próxima consulta (respeitando limites da OLX)...", timestamp_atual(), delay_secs));
                        tokio::time::sleep(std::time::Duration::from_secs(delay_secs as u64)).await;
                    }

                    passo_atual += 1;
                }
            }
        }

        registrar_log(&app_clone, &mut logs, format!("[{}] 🎉 Varredura completa finalizada! {} novos imóveis descobertos, {} removidos.", timestamp_atual(), novos_acumulado, removidos_acumulado));
    });

    Ok(SyncResult {
        success: true,
        batch_id: "iniciado".to_string(),
        target_url: "".to_string(),
        total_encontrados: 0,
        novos_encontrados: 0,
        removidos_encontrados: 0,
        logs: vec![],
        message: "Varredura iniciada em segundo plano".to_string(),
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
            fetch_server_config,
            sync_server_config,
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
