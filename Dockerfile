# ===================================================
# Moodle 4.5 LTS + IOMAD 4.5 — Public Base Image
# ===================================================
# Ready-to-use image with Moodle core and IOMAD multi-tenancy.
# All dependencies downloaded and installed at build time.
#
# Usage:
#   docker pull tquangkhai98/moodle-iomad:4.5
#   docker run -d -p 8080:80 tquangkhai98/moodle-iomad:4.5
#
# Build locally:
#   docker build -t moodle-iomad:4.5 .
#
# Build with custom versions:
#   docker build --build-arg MOODLE_VERSION=405 --build-arg IOMAD_BRANCH=IOMAD_45_STABLE -t moodle-iomad:4.5 .

# ===================================================
# Build Arguments
# ===================================================
ARG MOODLE_VERSION=405
ARG IOMAD_BRANCH=IOMAD_405_STABLE
ARG PHP_VERSION=8.3

# ===================================================
# Stage 1: Download dependencies
# ===================================================
FROM curlimages/curl:latest AS downloader

ARG MOODLE_VERSION
ARG IOMAD_BRANCH

WORKDIR /downloads

# Download Moodle
RUN curl -fSL -o moodle.tgz \
    "https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION}/moodle-latest-${MOODLE_VERSION}.tgz" \
    && echo "✅ Moodle downloaded"

# Download IOMAD
RUN curl -fSL -o iomad.tar.gz \
    "https://github.com/iomad/iomad/archive/refs/heads/${IOMAD_BRANCH}.tar.gz" \
    && echo "✅ IOMAD downloaded"

# ===================================================
# Stage 2: Extract & merge
# ===================================================
FROM moodlehq/moodle-php-apache:${PHP_VERSION}-bookworm AS extractor

COPY --from=downloader /downloads/moodle.tgz /tmp/
COPY --from=downloader /downloads/iomad.tar.gz /tmp/

# Extract Moodle
RUN tar -xzf /tmp/moodle.tgz -C /var/www/html --strip-components=1 \
    && rm /tmp/moodle.tgz

# Extract and overlay IOMAD plugins onto Moodle
RUN mkdir -p /tmp/iomad \
    && tar -xzf /tmp/iomad.tar.gz -C /tmp/iomad --strip-components=1 \
    && for dir in \
         local auth blocks admin/tool availability/condition \
         enrol filter lang lib mod report theme user/profile/field webservice; do \
         if [ -d "/tmp/iomad/$dir" ]; then \
           mkdir -p "/var/www/html/$dir" \
           && cp -r /tmp/iomad/$dir/* /var/www/html/$dir/ 2>/dev/null || true; \
         fi; \
       done \
    && rm -rf /tmp/iomad /tmp/iomad.tar.gz \
    && echo "✅ IOMAD installed"

# ===================================================
# Stage 3: Final clean image
# ===================================================
FROM moodlehq/moodle-php-apache:${PHP_VERSION}-bookworm

ARG MOODLE_VERSION
ARG IOMAD_BRANCH

# Copy extracted Moodle + IOMAD (no tarball layers in final image)
COPY --from=extractor /var/www/html /var/www/html

# Create moodledata directory
RUN mkdir -p /var/www/moodledata \
    && chown www-data:www-data /var/www/moodledata

# Bake permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 750 /var/www/html \
    && echo "✅ Permissions baked into image"

# ===================================================
# Metadata (OCI standard labels)
# ===================================================
LABEL org.opencontainers.image.title="Moodle + IOMAD" \
      org.opencontainers.image.description="Moodle 4.5 LTS with IOMAD multi-tenancy plugin pre-installed" \
      org.opencontainers.image.version="4.5" \
      org.opencontainers.image.vendor="tquangkhai98" \
      org.opencontainers.image.source="https://github.com/tquangkhai98/moodle-iomad-docker" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.base.name="moodlehq/moodle-php-apache:8.3-bookworm" \
      maintainer="tquangkhai98" \
      moodle.version="${MOODLE_VERSION}" \
      iomad.branch="${IOMAD_BRANCH}"

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1
