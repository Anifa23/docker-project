# ---------- Base (shared backend setup) ----------
FROM node:20-alpine AS base
WORKDIR /app
RUN apk add --no-cache python3 make g++
COPY backend/package*.json ./

# ---------- Development ----------
FROM base AS dev
ENV NODE_ENV=development
RUN npm ci && npm rebuild sqlite3
COPY backend/ .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# ---------- Test ----------
FROM base AS test
ENV NODE_ENV=test
RUN npm ci && npm rebuild sqlite3
COPY backend/ .
RUN npm test

# ---------- Backend production dependencies ----------
FROM base AS prod-deps
RUN npm ci --omit=dev && npm rebuild sqlite3

# ---------- Frontend build ----------
FROM node:20-alpine AS client-build
WORKDIR /client
COPY client/package*.json ./
RUN npm ci
COPY client/ .
RUN npm run build

# ---------- Production (final) ----------
FROM node:20-alpine AS final
ENV NODE_ENV=production
WORKDIR /app
COPY backend/package*.json ./
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=test /app/src ./src
COPY --from=client-build /client/dist ./src/static
RUN mkdir -p /etc/todos && chown -R node:node /etc/todos
EXPOSE 3000
USER node
CMD ["node", "src/index.js"]
