FROM nginx:latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends libnginx-mod-http-geoip2 ca-certificates \
 && rm -rf /var/lib/apt/lists/*