#!/bin/bash
set -e
cd /code

# (اختیاری) رستور بکاپ در اولین اجرا — اگه دیتابیس هنوز ساخته نشده
if [ -n "$BACKUP_URL" ] && [ ! -f /var/lib/marzban/db.sqlite3 ]; then
  echo "[entrypoint] restoring backup from $BACKUP_URL ..."
  curl -fsSL "$BACKUP_URL" -o /tmp/backup.zip || echo "backup download failed (ignored)"
  cd /tmp && unzip -o backup.zip -d /var/lib/marzban/ || true
  cd /code
fi

# مایگریشن دیتابیس (مثل CMD رسمی)
alembic upgrade head

# اجرای پنل — خودش Xray رو هم بهعنوان زیرپروسه بالا میاره
python main.py &
APP_PID=$!
trap 'kill $APP_PID 2>/dev/null' EXIT

# صبر تا بالا اومدن پنل
for i in $(seq 1 60); do
  curl -sf http://127.0.0.1:8000/api/ >/dev/null 2>&1 && break
  sleep 1
done

# پروکسی اصلی
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
