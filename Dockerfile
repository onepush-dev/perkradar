# PerkRadar on Railway: builds upstream luobinger/PerkRadar (MIT) at a pinned commit, app files unmodified.
# Same steps as upstream's root Dockerfile. Railway changes only: listens on 8080 (the port Railway injects
# and health-checks), Secure session cookie on, SQLite in the /data volume; a small start script chowns the
# root-owned Railway volume and then drops to the unprivileged node user, like upstream.
FROM node:22-bookworm-slim AS build
ARG PERKRADAR_REF=92c68cb5503bcbb1316d3fa9a21e20b9a86f3b3d
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git clone https://github.com/luobinger/PerkRadar.git . && git checkout "$PERKRADAR_REF" && rm -rf .git
RUN npm ci
RUN npm run build && npm prune --omit=dev

FROM node:22-bookworm-slim AS runtime
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/perkradar"
WORKDIR /app
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/next.config.mjs ./
COPY --from=build /app/scripts/serve.mjs ./scripts/serve.mjs
COPY railway-start.sh /usr/local/bin/railway-start.sh
ENV HOST=0.0.0.0 \
    PORT=8080 \
    NODE_ENV=production \
    DATA_DIR=/data \
    PERKRADAR_SECURE_COOKIE=1
RUN mkdir -p /data && chown -R node:node /data && chmod +x /usr/local/bin/railway-start.sh
EXPOSE 8080
CMD ["/usr/local/bin/railway-start.sh"]
