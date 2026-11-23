# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY assets/ ./assets/
COPY lib/ ./lib/
COPY web/ ./web/

RUN flutter build web --wasm --release

# Server stage
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

# nginx mime.types lacks .mjs -> served as octet-stream, Chrome refuses module scripts
RUN echo 'types { application/javascript mjs; }' > /etc/nginx/conf.d/mjs.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
