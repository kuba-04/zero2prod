FROM lukemathwalker/cargo-chef:latest-rust-1.77.2 as chef
WORKDIR /app

FROM chef as planner
COPY . .
# Compute a lock-like file for our project
RUN cargo chef prepare  --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build our project dependencies, not our application!
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
# Make sure sqlx-data.json is copied into the container
COPY sqlx-data.json sqlx-data.json
ENV SQLX_OFFLINE true
# Build our project
RUN cargo build --release --bin zero2prod

FROM debian:bookworm-slim AS runtime
WORKDIR /app
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/zero2prod zero2prod
COPY configuration/base.yaml configuration/base.yaml
COPY configuration/production.yaml.example configuration/production.yaml
ENV APP_ENVIRONMENT production
ENV DATABASE_URL postgres://postgres:password@postgres:5432/zero2prod
ENTRYPOINT ["./zero2prod"]