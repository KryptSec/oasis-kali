# oasis-kali

Curated Kali Linux container image for [OASIS](https://github.com/KryptSec/oasis) AI security benchmarking.

## Overview

This image provides a pentesting toolkit used as the runtime environment for OASIS benchmarks. The OASIS CLI orchestrates from the host via `docker exec` — this image provides the tools, not the agent.

Built on `kalilinux/kali-rolling` with individually selected packages (~1.5GB) instead of the `kali-linux-headless` metapackage (~7GB).

## Usage

```bash
docker pull ghcr.io/kryptsec/oasis-kali:latest
```

The image is consumed by [oasis-challenges](https://github.com/KryptSec/oasis-challenges) via `docker-compose.yml`:

```yaml
kali:
  image: ghcr.io/kryptsec/oasis-kali:latest
  platform: linux/amd64
  hostname: kali
  networks:
    - oasis-net
```

## Included Tools

| Category | Tools |
|---|---|
| Recon & Scanning | nmap, nikto, whatweb, wpscan, nuclei |
| Content Discovery | gobuster, ffuf, dirb, wfuzz |
| Exploitation | sqlmap, hydra, john, hashcat |
| HTTP / Networking | curl, wget, netcat, socat |
| Reverse Engineering | radare2, gdb, binwalk, binutils, xxd |
| Network Analysis | tshark, tcpdump |
| Forensics / Stego | exiftool, steghide, foremost |
| Scripting | python3, php, perl, bash |
| Wordlists | SecLists (full) |
| Python Libraries | requests, pwntools, beautifulsoup4, lxml |

See [tools.txt](tools.txt) for the machine-readable manifest used by the OASIS CLI to populate agent system prompts.

## Building Locally

```bash
docker build -t oasis-kali .
```

## CI/CD

Pushes to `main` that modify `Dockerfile` or `tools.txt` trigger a GitHub Actions workflow that builds and pushes to `ghcr.io/kryptsec/oasis-kali` with tags:
- `latest` (always tracks main)
- Git SHA (e.g., `abc1234`)
- Date stamp (e.g., `2026-02-19`)

## Related Repos

- [oasis](https://github.com/KryptSec/oasis) — CLI + orchestration engine
- [oasis-challenges](https://github.com/KryptSec/oasis-challenges) — Challenge definitions & target applications

## License

MIT
