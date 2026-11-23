# Build stage
# Community Flutter images (cirruslabs, instrumentisto) stopped updating; pin the SDK
# ourselves. Keep in sync with flutter-version in .github/workflows/release.yml.
FROM debian:trixie-slim AS builder

ARG FLUTTER_VERSION=3.50.1
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m flutter

# Non-root: Flutter warns as root, and root tar fails chown'ing SDK archives under rootless Podman
USER flutter
RUN git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /home/flutter/sdk
ENV PATH="/home/flutter/sdk/bin:$PATH"
RUN flutter config --no-analytics && flutter precache --web

WORKDIR /home/flutter/app

COPY --chown=flutter pubspec.yaml pubspec.lock ./
RUN flutter pub get --enforce-lockfile

COPY --chown=flutter assets/ ./assets/
COPY --chown=flutter lib/ ./lib/
COPY --chown=flutter web/ ./web/

RUN flutter build web --wasm --release

# Server stage
FROM nginx:alpine

COPY --from=builder /home/flutter/app/build/web /usr/share/nginx/html

# nginx mime.types lacks .mjs -> served as octet-stream, Chrome refuses module scripts
RUN echo 'types { application/javascript mjs; }' > /etc/nginx/conf.d/mjs.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
