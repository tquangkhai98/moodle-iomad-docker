# 🐳 Moodle + IOMAD Docker Image

[![Docker Hub](https://img.shields.io/docker/pulls/tquangkhai98/moodle-iomad?logo=docker&label=Docker%20Hub)](https://hub.docker.com/r/tquangkhai98/moodle-iomad)
[![Docker Image Size](https://img.shields.io/docker/image-size/tquangkhai98/moodle-iomad/latest?logo=docker&label=Image%20Size)](https://hub.docker.com/r/tquangkhai98/moodle-iomad)
[![GHCR](https://img.shields.io/badge/ghcr.io-moodle--iomad-blue?logo=github)](https://github.com/tquangkhai98/moodle-iomad-docker/pkgs/container/moodle-iomad)
[![Build](https://github.com/tquangkhai98/moodle-iomad-docker/actions/workflows/build-push.yml/badge.svg)](https://github.com/tquangkhai98/moodle-iomad-docker/actions/workflows/build-push.yml)
[![License](https://img.shields.io/github/license/tquangkhai98/moodle-iomad-docker?label=License)](LICENSE)

Pre-built, production-ready Docker images with **Moodle LMS** and **IOMAD** multi-tenancy plugin — available in multiple versions, for `amd64` and `arm64`.

> **IOMAD** (Industry's Moodle) adds multi-tenancy to Moodle, enabling you to manage multiple organizations/companies from a single Moodle installation.

---

## 🚀 Quick Start

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

---

## 📦 Available Versions

| Tag | Moodle | IOMAD | PHP | Status |
|-----|--------|-------|-----|--------|
| `5.0` | 5.0 | IOMAD 5.0 | 8.3 | 🆕 Latest |
| `4.5`, `latest` | 4.5 LTS | IOMAD 4.5 | 8.3 | ⭐ **Recommended** |
| `4.4` | 4.4 | IOMAD 4.4 | 8.3 | ✅ Supported |

> 💡 **Tip:** Use `:4.5` (LTS) for production — it's supported until **December 2028**.

### Registries

Images are published to **two registries** — pick whichever you prefer:

```bash
# Docker Hub
docker pull tquangkhai98/moodle-iomad:4.5

# GitHub Container Registry
docker pull ghcr.io/tquangkhai98/moodle-iomad:4.5
```

### Platforms

| Architecture | Examples |
|-------------|----------|
| `linux/amd64` | Standard servers, cloud VMs, Intel/AMD |
| `linux/arm64` | Apple Silicon (M1–M4), AWS Graviton, Raspberry Pi |

---

## 🧩 What's Included

Each image ships with:

- **Moodle Core** — Full LMS platform
- **Apache 2.x** — Web server (pre-configured)
- **PHP 8.3** — Runtime (Debian Bookworm)
- **IOMAD Plugin Suite:**

  | Plugin | Description |
  |--------|-------------|
  | `local/iomad` | Core IOMAD multi-tenancy engine |
  | `blocks/iomad_*` | Dashboard & company management blocks |
  | `auth/iomad` | Multi-tenant authentication |
  | `enrol/iomad` | Company-based enrollment |
  | `mod/trainingevent` | Training event management |
  | `theme/iomad` | IOMAD-compatible theme |
  | + more | All standard IOMAD plugins included |

---

## ⚙️ CI/CD & Releasing

This project uses **GitHub Actions** for fully automated builds and releases.

### How it works

```
Push tag v4.5.1
       │
       ├──▶ build-push.yml ──▶ Build 3 versions × 2 platforms × 2 registries
       │
       └──▶ release.yml ────▶ Create GitHub Release (auto changelog)
```

### Triggers

| Trigger | When | What happens |
|---------|------|-------------|
| 🏷️ `git push origin v*` | You tag a release | Build all versions + create Release |
| ▶️ Manual dispatch | GitHub Actions → Run workflow | Choose specific versions or `all` |
| 📅 Weekly schedule | Every Monday 6:00 UTC | Rebuild all to catch base image updates |

### Release a new version

```bash
git tag v4.5.1 -m "Patch update"
git push origin v4.5.1
# Done! GitHub Actions handles everything automatically.
```

---

## 🔧 Building Locally

```bash
# Clone the repo
git clone https://github.com/tquangkhai98/moodle-iomad-docker.git
cd moodle-iomad-docker

# Build (default: Moodle 4.5 + IOMAD 4.5)
docker build -t moodle-iomad:4.5 .

# Build a different version
docker build \
  --build-arg MOODLE_VERSION=500 \
  --build-arg IOMAD_BRANCH=IOMAD_500_STABLE \
  -t moodle-iomad:5.0 .
```

### Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `MOODLE_VERSION` | `405` | Moodle stable branch number (`405`, `404`, `500`) |
| `IOMAD_BRANCH` | `IOMAD_405_STABLE` | IOMAD GitHub branch |
| `PHP_VERSION` | `8.3` | PHP version for base image |

### Local Push to Docker Hub

```bash
docker login

# Build and push (multi-platform: amd64 + arm64)
./scripts/build-and-push.sh 4.5

# Dry run (build only, don't push)
DRY_RUN=true ./scripts/build-and-push.sh

# Single platform only
PLATFORMS=linux/amd64 ./scripts/build-and-push.sh 4.5
```

---

## 🧱 Extending This Image

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

---

## 📄 License

This Docker image packages [Moodle](https://moodle.org/) (GPL-3.0) and [IOMAD](https://www.iomad.org/) (GPL-3.0).
This project is licensed under [GPL-3.0](LICENSE).

## 🙏 Credits

- [Moodle HQ](https://moodle.org/) — Moodle LMS
- [IOMAD](https://www.iomad.org/) — Multi-tenancy plugin
- [moodlehq/moodle-php-apache](https://hub.docker.com/r/moodlehq/moodle-php-apache) — Base PHP/Apache image
