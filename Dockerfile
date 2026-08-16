# پایه: خودِ ایمیج رسمی Marzban v0.8.4 (پنل + Xray + پایتون، همه آماده)
FROM ghcr.io/gozargah/marzban:v0.8.4

# ابزارهای کمکی (برای بکاپ/رستور)
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Caddy — باینری رسمی (پایدارتر از apt روی slim)
RUN curl -fsSL "https://caddyserver.com/api/download?os=linux&arch=amd64" -o /usr/local/bin/caddy \
    && chmod +x /usr/local/bin/caddy

# پیکربندیها
COPY Caddyfile /etc/caddy/Caddyfile
COPY xray_config.json /var/lib/marzban/xray_config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && mkdir -p /var/lib/marzban

WORKDIR /code
EXPOSE 3000
CMD ["/entrypoint.sh"]
