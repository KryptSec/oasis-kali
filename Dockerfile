FROM kalilinux/kali-rolling

LABEL org.opencontainers.image.source="https://github.com/KryptSec/oasis-kali"
LABEL org.opencontainers.image.description="Curated Kali Linux container for OASIS AI security benchmarking"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive

# ============================================================
# OASIS Kali Container — Curated Pentesting Toolkit
#
# Purpose: Runtime environment for OASIS AI security benchmarks.
# The OASIS CLI orchestrates from the host via `docker exec`.
# This image provides the tools — not the agent.
#
# Base: kali-rolling (~150MB) with individual packages instead
# of kali-linux-headless metapackage (~7GB with 300+ tools).
# ============================================================

# --- Base system utilities ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    git \
    unzip \
    jq \
    dnsutils \
    iputils-ping \
    iproute2 \
    procps \
    && rm -rf /var/lib/apt/lists/*

# --- Recon, Scanning & Content Discovery ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nmap \
    nikto \
    whatweb \
    wpscan \
    nuclei \
    dirb \
    gobuster \
    ffuf \
    wfuzz \
    && rm -rf /var/lib/apt/lists/*

# --- Exploitation ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sqlmap \
    hydra \
    john \
    hashcat \
    && rm -rf /var/lib/apt/lists/*

# --- HTTP / Networking ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    netcat-openbsd \
    socat \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# --- Reverse Engineering ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    radare2 \
    gdb \
    binutils \
    binwalk \
    file \
    xxd \
    && rm -rf /var/lib/apt/lists/*

# --- Network / PCAP Analysis ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tshark \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

# --- Forensics / Stego ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    exiftool \
    steghide \
    foremost \
    && rm -rf /var/lib/apt/lists/*

# --- Python 3 + pentest libraries ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages \
    requests==2.32.3 \
    pwntools==4.13.1 \
    beautifulsoup4==4.12.3 \
    lxml==5.3.0

# --- Scripting ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    php-cli \
    perl \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Wordlists — SecLists
# ============================================================
RUN git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists && \
    rm -rf /usr/share/seclists/.git

# ============================================================
# Tool manifest — read by OASIS CLI to populate system prompt
# ============================================================
COPY tools.txt /app/tools.txt

# ============================================================
# Non-root user
# ============================================================
RUN useradd -m -s /bin/bash oasis && \
    mkdir -p /app/results && \
    chown -R oasis:oasis /app

USER oasis
WORKDIR /app

CMD ["sleep", "infinity"]
