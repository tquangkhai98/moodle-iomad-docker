# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker image project that bundles **Moodle 4.5 LTS** with **IOMAD 4.5** (multi-tenancy plugin suite) into a production-ready container. Base image is `moodlehq/moodle-php-apache` with PHP 8.3 on Debian Bookworm.

## Build & Run Commands

```bash
# Build the image locally
docker build -t moodle-iomad:4.5 .

# Build with custom versions
docker build \
  --build-arg MOODLE_VERSION=405 \
  --build-arg IOMAD_BRANCH=IOMAD_405_STABLE \
  --build-arg PHP_VERSION=8.3 \
  -t moodle-iomad:4.5 .

# Run with docker compose (includes PostgreSQL)
docker compose up -d

# Build and push multi-platform image to Docker Hub
./scripts/build-and-push.sh 4.5

# Dry run (build only, no push)
DRY_RUN=true ./scripts/build-and-push.sh
```

## Architecture

### Dockerfile: 3-Stage Multi-Stage Build

1. **Downloader** (`curlimages/curl`) — Downloads Moodle tarball and IOMAD release archive
2. **Extractor** (`moodlehq/moodle-php-apache`) — Extracts Moodle, then overlays IOMAD plugins into the Moodle directory tree (local, auth, blocks, admin/tool, enrol, mod, theme, etc.)
3. **Final** (`moodlehq/moodle-php-apache`) — Copies merged source, creates `/var/www/moodledata`, sets permissions (www-data:www-data, 750), exposes port 80, adds health check

### Build Arguments

| Argument | Default | Purpose |
|----------|---------|---------|
| `MOODLE_VERSION` | `405` | Moodle stable branch number |
| `IOMAD_BRANCH` | `IOMAD_405_STABLE` | IOMAD GitHub branch |
| `PHP_VERSION` | `8.3` | PHP version for base image |

### CI/CD

GitHub Actions workflow (`.github/workflows/build-push.yml`) triggers on:
- Git tags matching `v*` (automatic)
- Manual `workflow_dispatch` with version/branch inputs

Builds multi-platform images (`linux/amd64` + `linux/arm64`) via `docker buildx` and pushes to Docker Hub (`tquangkhai98/moodle-iomad`). Requires `DOCKERHUB_TOKEN` secret.

### Build Script (`scripts/build-and-push.sh`)

Configurable via environment variables: `DOCKER_HUB_USER`, `IMAGE_NAME`, `VERSION`, `PLATFORMS`, `DRY_RUN`. Handles automatic version tagging (e.g., v4.5.1 → tags: 4.5.1, 4.5, latest).
