# Build stage
FROM rust:latest as builder

WORKDIR /usr/src/app
COPY . .

# Compila o binário otimizado
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia o binário e as pastas necessárias (ex: templates)
COPY --from=builder /usr/src/app/target/release/imoviu_app /app/imoviu_app
COPY --from=builder /usr/src/app/templates /app/templates

ENV PORT=8080
EXPOSE 8080

CMD ["./imoviu_app"]
