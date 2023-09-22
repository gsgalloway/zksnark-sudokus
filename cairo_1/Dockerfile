FROM rustlang/rust:nightly-bullseye-slim as dependencies

ARG CAIRO_VERSION="2.2.0"
ARG SCARB_VERSION="0.7.0"

# Install required dependencies
RUN apt-get update && \
    apt-get install -y git wget

WORKDIR /

RUN wget https://github.com/starkware-libs/cairo/releases/download/v${CAIRO_VERSION}/release-x86_64-unknown-linux-musl.tar.gz && \
    tar -xvf ./release-x86_64-unknown-linux-musl.tar.gz

RUN ln -s /cairo/bin/cairo-compile /bin/ && \
    ln -s /cairo/bin/sierra-compile /bin/ && \
    ln -s /cairo/bin/cairo-run /bin/ && \
    ln -s /cairo/bin/cairo-test /bin/

RUN wget https://github.com/software-mansion/scarb/releases/download/v${SCARB_VERSION}/scarb-v${SCARB_VERSION}-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xvf ./scarb-v${SCARB_VERSION}-x86_64-unknown-linux-gnu.tar.gz && \
    cp ./scarb-v${SCARB_VERSION}-x86_64-unknown-linux-gnu/bin/* /bin/ && \
    rm -rf ./scarb-v${SCARB_VERSION}-x86_64-unknown-linux-gnu*

WORKDIR /sudoku
