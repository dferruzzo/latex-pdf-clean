FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install TeX Live from the official CTAN network (latest release).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    fontconfig \
    perl \
    wget \
    xz-utils \
    tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget -qO- https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    | tar -xz && \
    install_dir="$(find . -maxdepth 1 -type d -name 'install-tl-*' | head -n 1)" && \
    printf '%s\n' \
      "selected_scheme scheme-full" \
      "TEXDIR /opt/texlive" \
      "TEXMFLOCAL /opt/texlive/texmf-local" \
      "TEXMFSYSCONFIG /opt/texlive/texmf-config" \
      "TEXMFSYSVAR /opt/texlive/texmf-var" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/texlive.profile && \
    ./${install_dir}/install-tl -profile /tmp/texlive.profile && \
    /opt/texlive/bin/x86_64-linux/tlmgr update --self --all && \
    rm -rf /tmp/*

ENV PATH="/opt/texlive/bin/x86_64-linux:${PATH}"

WORKDIR /data
ENTRYPOINT ["pdflatex"]
