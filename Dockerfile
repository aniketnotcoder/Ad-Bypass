FROM python:3.12-slim

# xvfb lets us run a *headful* Chromium (far better at clearing Cloudflare than
# plain headless). xauth is required by xvfb-run; ca-certificates for TLS.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       xvfb \
       xauth \
       ca-certificates \
       libatomic1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && playwright install --with-deps chromium

COPY bot.py resolver.py ./

# HEADLESS=false (default) + xvfb-run => headful browser inside a virtual display.
ENV HEADLESS=false \
    PYTHONUNBUFFERED=1

# Emit a startup marker before launching the bot so Railway logs distinguish
# an Xvfb startup failure from a Python/Telegram initialization failure.
CMD ["sh", "-c", "echo '[startup] launching Xvfb and AroLinks bot'; exec xvfb-run -a python -u bot.py"]
