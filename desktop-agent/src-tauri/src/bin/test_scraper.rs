use headless_chrome::{Browser, LaunchOptionsBuilder};
use std::ffi::OsStr;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("=== TESTE DE RASPADOR AO VIVO (OLX) ===");
    let url = "https://www.olx.com.br/imoveis/venda/casas/estado-pe?f=p&q=petrolina";
    println!("1. Conectando via Headless Chrome à URL: {}", url);

    let args: Vec<&OsStr> = vec![
        OsStr::new("--disable-blink-features=AutomationControlled"),
        OsStr::new("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"),
        OsStr::new("--no-sandbox"),
        OsStr::new("--disable-setuid-sandbox"),
    ];

    let options = LaunchOptionsBuilder::default()
        .headless(true)
        .args(args)
        .build()?;

    let browser = Browser::new(options)?;
    let tab = browser.new_tab()?;

    println!("2. Navegando para {}", url);
    tab.navigate_to(url)?;
    let _ = tab.wait_until_navigated();

    println!("3. Aguardando 4s de carregamento dinâmico...");
    sleep(Duration::from_secs(4)).await;

    let html = tab.get_content()?;
    println!("4. Tamanho do HTML retornado: {} bytes", html.len());

    let re_href = regex::Regex::new(r#"href="(https://[a-z0-9\.-]*olx\.com\.br/[^"]*?-\d+)""#).unwrap();
    let re_card_title = regex::Regex::new(r#"olx-adcard__title[^>]*>([^<]+)<"#).unwrap();

    let mut matches = Vec::new();
    for cap in re_href.captures_iter(&html) {
        if let Some(m) = cap.get(1) {
            matches.push(m.as_str().to_string());
        }
    }

    println!("5. Links de anúncios encontrados no DOM: {}", matches.len());
    for (idx, link) in matches.iter().take(5).enumerate() {
        let pos = html.find(link).unwrap_or(0);
        let window = &html[pos.saturating_sub(1000)..(pos + 6500).min(html.len())];
        let titulo = re_card_title.captures(window).map(|c| c.get(1).unwrap().as_str().trim().to_string()).unwrap_or_else(|| "Sem título específico".to_string());
        println!("   [{}] Titulo: {} | Link: {}", idx + 1, titulo, link);
    }

    if matches.is_empty() {
        if html.contains("Cloudflare") || html.contains("Attention Required") {
            println!("⚠️ BLOQUEADO POR CLOUDFLARE!");
        } else {
            println!("⚠️ Nenhum anúncio encontrado.");
        }
    } else {
        println!("✅ SUCESSO! O raspador está capturando anúncios ao vivo!");
    }

    Ok(())
}
