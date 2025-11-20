# Multi-stage Dockerfile for a Vite app (build -> nginx)

# --- Build stage ---
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies first (better layer caching)
COPY package*.json ./
RUN npm ci --no-audit --no-fund

# Copy the rest of the source and build
COPY . .
RUN npm run build

# --- Runtime stage ---
FROM nginx:alpine

# Copy built assets to Nginx html directory
COPY --from=build /app/dist /usr/share/nginx/html

# Optional: reduce default Nginx logs noise in container env
# (Uncomment if desired)
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#     && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
