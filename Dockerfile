# ---- build stage ----
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY . .
RUN npm run build

# ---- runtime stage ----
FROM node:20-alpine AS runner
ENV NODE_ENV=production
WORKDIR /app

COPY package.json package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi
COPY --from=builder /app/dist ./dist

# ✅ ensure logs dir exists and is writable by non-root
RUN mkdir -p /app/logs && chown -R node:node /app
USER node

# ✅ your app prints “Server listening on port 3000”
ENV PORT=3000
EXPOSE 3000

CMD ["node", "dist/app.js"]

