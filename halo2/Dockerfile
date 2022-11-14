FROM rustlang/rust:nightly-bullseye-slim as dependencies

WORKDIR /sudoku

COPY Cargo.toml .
COPY Cargo.lock .

RUN mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    cargo fetch


FROM rustlang/rust:nightly-bullseye-slim as application

RUN apt-get update && apt-get install -y \
    pkg-config \
    libfontconfig \
    libfontconfig1-dev

WORKDIR /sudoku

COPY --from=dependencies /sudoku/Cargo.toml .
COPY --from=dependencies /usr/local/cargo /usr/local/cargo

COPY src/ src/

VOLUME /output

RUN cargo build -Z unstable-options
