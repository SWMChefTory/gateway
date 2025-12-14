ARG NGINX_VERSION=1.28.0

FROM nginx:${NGINX_VERSION} AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git wget ca-certificates \
    libmaxminddb-dev \
    libpcre2-dev zlib1g-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 https://github.com/leev/ngx_http_geoip2_module.git
RUN wget -qO- http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar zx

WORKDIR /build/nginx-${NGINX_VERSION}
RUN ./configure --with-compat --add-dynamic-module=/build/ngx_http_geoip2_module \
 && make modules

FROM nginx:${NGINX_VERSION}
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmaxminddb0 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/nginx-${NGINX_VERSION}/objs/ngx_http_geoip2_module.so /etc/nginx/modules/