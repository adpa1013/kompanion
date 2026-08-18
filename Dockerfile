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

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
