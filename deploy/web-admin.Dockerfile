FROM node:20-alpine AS build

WORKDIR /workspace
RUN corepack enable
COPY web-admin/package.json web-admin/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY web-admin ./
RUN pnpm run build

FROM nginx:1.27-alpine

COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /workspace/dist /usr/share/nginx/html

EXPOSE 80
