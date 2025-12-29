# ---------- BASE ----------
FROM node:22-alpine AS base
WORKDIR /app
COPY package.json yarn.lock ./

# ---------- DEPENDENCIES ----------
FROM base AS deps
RUN yarn install --frozen-lockfile

# ---------- TEST ----------
FROM deps AS test
COPY . .
RUN yarn test

# ---------- BUILD ----------
FROM deps AS build
COPY . .
RUN yarn build

# ---------- FINAL ----------
FROM nginx:alpine AS final
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
