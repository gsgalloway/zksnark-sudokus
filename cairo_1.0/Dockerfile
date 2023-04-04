FROM rustlang/rust:nightly-bullseye-slim as dependencies

ARG CAIRO_VERSION="v1.0.0-alpha.6"

# Install required dependencies
RUN apt-get update && \
    apt-get install -y git

WORKDIR /

RUN git clone https://github.com/starkware-libs/cairo.git && \
    cd cairo && \
    git checkout ${CAIRO_VERSION} && \
    cargo build --release \
    --package cairo-lang-compiler --bin cairo-compile \
    --package cairo-lang-sierra-to-casm --bin sierra-compile \
    --package cairo-lang-runner --bin cairo-run

RUN ln -s /cairo/target/release/cairo-compile /usr/bin/ && \
    ln -s /cairo/target/release/sierra-compile /usr/bin/ && \
    ln -s /cairo/target/release/cairo-run /usr/bin/

WORKDIR /sudoku
