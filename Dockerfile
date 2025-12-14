FROM nginx:latest AS builder

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    build-essential ca-certificates git wget \
    libmaxminddb-dev \
    libpcre3-dev zlib1g-dev libssl-dev; \
  rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  NGINX_VERSION="$(nginx -v 2>&1 | sed -n 's|nginx version: nginx/||p')"; \
  CONFIG_ARGS="$(nginx -V 2>&1 | sed -n 's/^configure arguments: //p')"; \
  wget -q "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O /tmp/nginx.tar.gz; \
  tar -xzf /tmp/nginx.tar.gz -C /tmp; \
  mv "/tmp/nginx-${NGINX_VERSION}" /tmp/nginx-src; \
  git clone --depth 1 https://github.com/leev/ngx_http_geoip2_module.git /tmp/ngx_http_geoip2_module; \
  cd /tmp/nginx-src; \
  eval "./configure --with-compat ${CONFIG_ARGS} --add-dynamic-module=/tmp/ngx_http_geoip2_module"; \
  make modules; \
  test -f objs/ngx_http_geoip2_module.so

FROM nginx:latest

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends libmaxminddb0 ca-certificates; \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/nginx-src/objs/ngx_http_geoip2_module.so /usr/lib/nginx/modules/ngx_http_geoip2_module.so