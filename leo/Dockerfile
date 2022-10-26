FROM rust:1.64.0

# Install Aleo
RUN cd /tmp && \
    git clone https://github.com/AleoHQ/aleo.git && \
    cd aleo && \
    git checkout 901453f1a9f1f38c5b3efaef0b1eddf21060c0bc && \
    cargo install --path .

# Install Leo
RUN cd /tmp && \
    git clone https://github.com/AleoHQ/leo.git && \
    cd leo && \
    git checkout ebd06d292af87991a87a9eebfc3f541b91127d9e && \
    cargo install --path .

# Download prover paramters (several ~200mb files)
RUN cd /tmp && \
    leo new install > /dev/null 2>&1 && \
    cd install && \
    leo build
