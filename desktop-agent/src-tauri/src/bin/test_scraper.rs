use headless_chrome::{Browser, LaunchOptionsBuilder};
use std::ffi::OsStr;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let url = "https://www.olx.com.br/imoveis/venda/casas/estado-pe?f=p&q=petrolina";

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
    tab.navigate_to(url)?;
    let _ = tab.wait_until_navigated();
    sleep(Duration::from_secs(4)).await;

    let html = tab.get_content()?;

    let re_href = regex::Regex::new(r#"href="(https://[a-z0-9\.-]*olx\.com\.br/[^"]*?-\d+)""#).unwrap();

    let mut imoveis = Vec::new();
    let mut outros = Vec::new();

    for cap in re_href.captures_iter(&html) {
        if let Some(m) = cap.get(1) {
            let link = m.as_str().to_string();
            if link.contains("/imoveis/") || link.contains("/terrenos/") || link.contains("/apartamentos/") || link.contains("/casas/") {
                imoveis.push(link);
            } else {
                outros.push(link);
            }
        }
    }

    println!("Imóveis reais encontrados ({}):", imoveis.len());
    for l in imoveis.iter().take(5) {
        println!("  🏠 {}", l);
    }

    println!("\nOutros (não-imóveis) encontrados ({}):", outros.len());
    for l in outros.iter().take(5) {
        println!("  🚫 {}", l);
    }

    Ok(())
}
