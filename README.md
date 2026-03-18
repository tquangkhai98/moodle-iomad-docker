# 🐳 Moodle + IOMAD Docker Image

[![Docker Hub](https://img.shields.io/docker/pulls/tquangkhai98/moodle-iomad)](https://hub.docker.com/r/tquangkhai98/moodle-iomad)
[![Docker Image Size](https://img.shields.io/docker/image-size/tquangkhai98/moodle-iomad/latest)](https://hub.docker.com/r/tquangkhai98/moodle-iomad)
[![GHCR](https://img.shields.io/badge/ghcr.io-moodle--iomad-blue?logo=github)](https://github.com/tquangkhai98/moodle-iomad-docker/pkgs/container/moodle-iomad)
[![Build](https://github.com/tquangkhai98/moodle-iomad-docker/actions/workflows/build-push.yml/badge.svg)](https://github.com/tquangkhai98/moodle-iomad-docker/actions/workflows/build-push.yml)

Pre-built Docker images with **Moodle** and **IOMAD** multi-tenancy plugin installed and ready to use.

> **IOMAD** (Industry's Moodle) adds multi-tenancy to Moodle, enabling you to manage multiple organizations/companies from a single Moodle installation.

## Quick Start

```bash
# Docker Hub
docker pull tquangkhai98/moodle-iomad:4.5

# GitHub Packages (alternative)
docker pull ghcr.io/tquangkhai98/moodle-iomad:4.5
```

### Docker Compose (Recommended)

```yaml
services:
  moodle:
    image: tquangkhai98/moodle-iomad:4.5
    ports:
      - "8080:80"
    volumes:
      - moodledata:/var/www/moodledata
      - ./config.php:/var/www/html/config.php  # Your custom config
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: moodle
      POSTGRES_USER: moodle
      POSTGRES_PASSWORD: moodle_password
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  moodledata:
  pgdata:
```

```bash
docker compose up -d
# Open http://localhost:8080 to complete Moodle installation
```

### Docker Run

```bash
docker run -d \
  --name moodle \
  -p 8080:80 \
  -v moodledata:/var/www/moodledata \
  tquangkhai98/moodle-iomad:4.5
```

## What's Included

| Component | Version | Description |
|-----------|---------|-------------|
| Moodle | 4.5 LTS | Core LMS platform |
| IOMAD | 4.5 | Multi-tenancy plugin suite |
| PHP | 8.3 | Runtime (Debian Bookworm) |
| Apache | 2.x | Web server |

### IOMAD Plugins Installed

- `local/iomad` — Core IOMAD functionality
- `blocks/iomad_*` — Dashboard & company blocks
- `auth/iomad` — Multi-tenant authentication
- `enrol/iomad` — Company-based enrollment
- `mod/trainingevent` — Training event management
- `theme/iomad` — IOMAD-compatible theme
- And more (all standard IOMAD plugins)

## Available Versions

| Tag | Moodle | IOMAD | PHP | Status |
|-----|--------|-------|-----|--------|
| `5.0` | 5.0 | IOMAD 5.0 | 8.3 | Latest |
| `4.5`, `latest` | 4.5 LTS | IOMAD 4.5 | 8.3 | ⭐ Recommended |
| `4.4` | 4.4 | IOMAD 4.4 | 8.3 | Supported |

Images are available on both registries:
- **Docker Hub:** `tquangkhai98/moodle-iomad:<tag>`
- **GitHub Packages:** `ghcr.io/tquangkhai98/moodle-iomad:<tag>`

## Platforms

- `linux/amd64` — Standard servers, cloud VMs
- `linux/arm64` — Apple Silicon (M1/M2/M3), AWS Graviton, Raspberry Pi

## Building Locally

```bash
# Clone the repo
git clone https://github.com/tquangkhai98/moodle-iomad-docker.git
cd moodle-iomad-docker

# Build
docker build -t moodle-iomad:4.5 .

# Build with custom versions
docker build \
  --build-arg MOODLE_VERSION=405 \
  --build-arg IOMAD_BRANCH=IOMAD_405_STABLE \
  --build-arg PHP_VERSION=8.3 \
  -t moodle-iomad:4.5 .
```

### Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `MOODLE_VERSION` | `405` | Moodle stable branch number |
| `IOMAD_BRANCH` | `IOMAD_405_STABLE` | IOMAD GitHub branch |
| `PHP_VERSION` | `8.3` | PHP version for base image |

### Push to Docker Hub

```bash
# Login first
docker login

# Build and push (multi-platform)
./scripts/build-and-push.sh 4.5

# Dry run (build only, don't push)
DRY_RUN=true ./scripts/build-and-push.sh

# Single platform only
PLATFORMS=linux/amd64 ./scripts/build-and-push.sh 4.5
```

## Extending This Image

Use this as a base image for your own Moodle setup:

```dockerfile
FROM tquangkhai98/moodle-iomad:4.5

# Add your custom plugins
COPY my-plugin /var/www/html/local/my-plugin

# Add your config
COPY config.php /var/www/html/config.php

# Add custom entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
```

## License

This Docker image packages [Moodle](https://moodle.org/) (GPL-3.0) and [IOMAD](https://www.iomad.org/) (GPL-3.0). This project is licensed under GPL-3.0.

## Credits

- [Moodle HQ](https://moodle.org/) — Moodle LMS
- [IOMAD](https://www.iomad.org/) — Multi-tenancy plugin
- [moodlehq/moodle-php-apache](https://hub.docker.com/r/moodlehq/moodle-php-apache) — Base PHP/Apache image
