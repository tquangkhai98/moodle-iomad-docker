#!/bin/bash
# ===================================================
# Build and Push Moodle + IOMAD image to Docker Hub
# ===================================================
# Usage:
#   ./scripts/build-and-push.sh                   # Push as :4.5 and :latest
#   ./scripts/build-and-push.sh 4.5.1             # Push as :4.5.1, :4.5, and :latest
#   DRY_RUN=true ./scripts/build-and-push.sh      # Build only, don't push
#   PLATFORMS=linux/amd64 ./scripts/build-and-push.sh  # Single platform

set -euo pipefail

# ===================================================
# Configuration
# ===================================================
DOCKER_HUB_USER="${DOCKER_HUB_USER:-tquangkhai98}"
IMAGE_NAME="${IMAGE_NAME:-moodle-iomad}"
FULL_IMAGE="${DOCKER_HUB_USER}/${IMAGE_NAME}"

VERSION="${1:-4.5}"
MAJOR_MINOR=$(echo "$VERSION" | grep -oE '^[0-9]+\.[0-9]+')
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
DRY_RUN="${DRY_RUN:-false}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🐳 Moodle + IOMAD Docker Image Builder${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Image:     ${GREEN}${FULL_IMAGE}${NC}"
echo -e "  Version:   ${GREEN}${VERSION}${NC}"
echo -e "  Platforms: ${GREEN}${PLATFORMS}${NC}"
echo -e "  Dry run:   ${YELLOW}${DRY_RUN}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ===================================================
# Pre-flight checks
# ===================================================
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

if [ "$DRY_RUN" != "true" ]; then
    # Check Docker Hub login
    if ! docker info 2>/dev/null | grep -q "Username"; then
        echo -e "${YELLOW}🔐 Please login to Docker Hub first:${NC}"
        docker login
    fi
fi

# ===================================================
# Setup buildx builder
# ===================================================
BUILDER_NAME="moodle-iomad-builder"
echo -e "${BLUE}🔧 Setting up buildx builder...${NC}"

if ! docker buildx inspect "$BUILDER_NAME" &>/dev/null; then
    docker buildx create --name "$BUILDER_NAME" --driver docker-container --use
else
    docker buildx use "$BUILDER_NAME"
fi
docker buildx inspect --bootstrap > /dev/null 2>&1

# ===================================================
# Build tags
# ===================================================
TAGS="--tag ${FULL_IMAGE}:${VERSION} --tag ${FULL_IMAGE}:${MAJOR_MINOR} --tag ${FULL_IMAGE}:latest"
echo -e "${BLUE}🏷️  Tags:${NC}"
echo "  - ${FULL_IMAGE}:${VERSION}"
echo "  - ${FULL_IMAGE}:${MAJOR_MINOR}"
echo "  - ${FULL_IMAGE}:latest"
echo ""

# ===================================================
# Build
# ===================================================
PUSH_FLAG=""
if [ "$DRY_RUN" != "true" ]; then
    PUSH_FLAG="--push"
    echo -e "${BLUE}🏗️  Building and pushing...${NC}"
else
    PUSH_FLAG="--load"
    # --load doesn't support multi-platform, fall back to single
    PLATFORMS="linux/$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')"
    echo -e "${YELLOW}🏗️  Building locally (dry run, single platform: ${PLATFORMS})...${NC}"
fi

BUILD_START=$(date +%s)

docker buildx build \
    --platform "${PLATFORMS}" \
    ${TAGS} \
    ${PUSH_FLAG} \
    --file Dockerfile \
    .

BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$DRY_RUN" = "true" ]; then
    echo -e "${GREEN}✅ Build completed in ${BUILD_DURATION}s (dry run — not pushed)${NC}"
else
    echo -e "${GREEN}✅ Built and pushed in ${BUILD_DURATION}s${NC}"
    echo -e "${GREEN}📥 Pull: docker pull ${FULL_IMAGE}:${VERSION}${NC}"
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
