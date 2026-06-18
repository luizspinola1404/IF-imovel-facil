# Build scraper stage
FROM rust:alpine AS scraper-builder
WORKDIR /app
RUN apk add --no-cache musl-dev
COPY scraper ./scraper
WORKDIR /app/scraper
RUN cargo build --release

# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install build dependencies for native modules
RUN apk add --no-cache python3 make g++ postgresql-dev

# Install all dependencies (including dev dependencies for building)
RUN npm ci

# Copy application code
COPY . .

# Build the application
RUN npm run build
# write build timestamp to be served with static files for version/debugging
RUN node -e "require('fs').writeFileSync('dist/public/build_time.txt', new Date().toISOString())"

# Production stage
FROM node:20-alpine

# Install runtime dependencies for the scraper
RUN apk add --no-cache firefox geckodriver dbus

WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy node_modules from builder (includes all dependencies needed for externals)
COPY --from=builder /app/node_modules ./node_modules

# Copy built application from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/drizzle.config.ts ./drizzle.config.ts
COPY --from=builder /app/shared ./shared

# Copy the compiled scraper binary
COPY --from=scraper-builder /app/scraper/target/release/scraper ./scraper/target/release/scraper

# Expose port
EXPOSE 5000

# Set environment to production
ENV NODE_ENV=production

# Start the application
CMD ["node", "dist/index.cjs"]
