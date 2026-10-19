use axum::{
    extract::{Path, State},
    response::{Html, IntoResponse},
    routing::get,
    Router,
};
use serde::Serialize;
use std::env;
use std::net::SocketAddr;
use std::sync::Arc;
use tera::Tera;

#[derive(Serialize)]
struct Owner {
    name: String,
    role: String,
    creci: String,
    avatar: String,
    whatsapp: String,
    instagram: String,
    phone: String,
    email: String,
}

#[allow(dead_code)]
#[derive(Serialize)]
struct Property {
    title: String,
    type_name: String, // 'type' é palavra reservada em Tera, enviado no contexto como 'type'
    price: String,
    city: String,
    bedrooms: u8,
    bathrooms: u8,
    area: u16,
    description: String,
    cover_image: String,
    imovel_facil_url: String,
}

struct AppState {
    tera: Tera,
}

#[tokio::main]
async fn main() {
    let tera = match Tera::new("templates/**/*") {
        Ok(t) => t,
        Err(e) => {
            println!("Parsing error(s): {}", e);
            std::process::exit(1);
        }
    };

    let state = Arc::new(AppState { tera });

    let app = Router::new()
        .route("/", get(home_handler))
        .route("/q/:token", get(nfc_handler))
        .route("/nfc/:token", get(nfc_handler))
        .route("/imovel/:token", get(property_detail_handler))
        .route("/dashboard", get(dashboard_handler))
        .route("/admin", get(dashboard_handler))
        .with_state(state);

    let port: u16 = env::var("PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse()
        .expect("PORT must be a valid number");

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    println!("Listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn home_handler(State(state): State<Arc<AppState>>) -> impl IntoResponse {
    render_nfc_page(&state.tera, "demo")
}

async fn nfc_handler(
    Path(token): Path<String>,
    State(state): State<Arc<AppState>>,
) -> impl IntoResponse {
    render_nfc_page(&state.tera, &token)
}

async fn property_detail_handler(
    Path(token): Path<String>,
    State(state): State<Arc<AppState>>,
) -> impl IntoResponse {
    render_detail_page(&state.tera, &token)
}

async fn dashboard_handler(State(state): State<Arc<AppState>>) -> impl IntoResponse {
    render_dashboard_page(&state.tera)
}

fn render_nfc_page(tera: &Tera, token: &str) -> Html<String> {
    let mut context = tera::Context::new();

    let owner = Owner {
        name: "Luiz Spinola".to_string(),
        role: "Corretor & Consultor Imobiliário".to_string(),
        creci: "CRECI 12.345-F".to_string(),
        avatar: "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=400&q=80".to_string(),
        whatsapp: "5511999999999".to_string(),
        instagram: "luizspinolaimoveis".to_string(),
        phone: "+55 11 99999-9999".to_string(),
        email: "contato@luizspinolaimoveis.com.br".to_string(),
    };

    let property = serde_json::json!({
        "title": "Apartamento de Alto Padrão",
        "type": "Apartamento",
        "price": "850.000,00",
        "city": "São Paulo - SP",
        "bedrooms": 3,
        "bathrooms": 2,
        "area": 115,
        "description": "Excelente apartamento com acabamento em porcelanato, varanda gourmet envidraçada, 2 vagas cobertas e área de lazer completa no condomínio.",
        "cover_image": "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80",
        "imovel_facil_url": format!("https://luizspinolaimoveis.com.br/imovel/{}", token)
    });

    context.insert("token", token);
    context.insert("owner", &owner);
    context.insert("property", &property);

    match tera.render("property_nfc.html", &context) {
        Ok(rendered) => Html(rendered),
        Err(err) => Html(format!("Error rendering template: {}", err)),
    }
}

fn render_detail_page(tera: &Tera, token: &str) -> Html<String> {
    let mut context = tera::Context::new();

    let owner = Owner {
        name: "Luiz Spinola".to_string(),
        role: "Corretor & Consultor Imobiliário".to_string(),
        creci: "CRECI 12.345-F".to_string(),
        avatar: "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=400&q=80".to_string(),
        whatsapp: "5511999999999".to_string(),
        instagram: "luizspinolaimoveis".to_string(),
        phone: "+55 11 99999-9999".to_string(),
        email: "contato@luizspinolaimoveis.com.br".to_string(),
    };

    let property = serde_json::json!({
        "title": "Apartamento de Alto Padrão",
        "type": "Apartamento",
        "price": "850.000,00",
        "city": "São Paulo - SP",
        "bedrooms": 3,
        "bathrooms": 2,
        "area": 115,
        "description": "Excelente apartamento com acabamento em porcelanato de alto brilho, varanda gourmet envidraçada integrada à sala, 2 vagas cobertas e fixas, suíte master com closet. Condomínio clube completo com piscina aquecida, academia, quadra poliesportiva, salão de festas e portaria com segurança 24h.",
        "cover_image": "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80",
    });

    context.insert("token", token);
    context.insert("owner", &owner);
    context.insert("property", &property);

    match tera.render("property_detail.html", &context) {
        Ok(rendered) => Html(rendered),
        Err(err) => Html(format!("Error rendering template: {}", err)),
    }
}

fn render_dashboard_page(tera: &Tera) -> Html<String> {
    let mut context = tera::Context::new();

    let owner = Owner {
        name: "Luiz Spinola".to_string(),
        role: "Corretor & Consultor Imobiliário".to_string(),
        creci: "CRECI 12.345-F".to_string(),
        avatar: "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=400&q=80".to_string(),
        whatsapp: "5511999999999".to_string(),
        instagram: "luizspinolaimoveis".to_string(),
        phone: "+55 11 99999-9999".to_string(),
        email: "contato@luizspinolaimoveis.com.br".to_string(),
    };

    context.insert("owner", &owner);

    match tera.render("dashboard.html", &context) {
        Ok(rendered) => Html(rendered),
        Err(err) => Html(format!("Error rendering template: {}", err)),
    }
}

