# syntax=docker/dockerfile:1
# Flutter web app for Google Cloud Run (static site via nginx).
# Build context: mobile_app/  (see DEPLOY_CLOUD_RUN.md)

FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Backend URL baked into the web build (override at build time).
ARG API_BASE_URL=https://demo-mcp-615058378594.europe-west1.run.app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

RUN flutter build web --release \
  --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine

# Cloud Run sends traffic to the port in $PORT (default 8080).
ENV PORT=8080
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080
