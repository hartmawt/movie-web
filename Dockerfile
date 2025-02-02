#FROM node:20-alpine as build
FROM $BUILD_FROM as build
WORKDIR /app
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

COPY package.json ./
COPY pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

ARG PWA_ENABLED="false"
ARG GA_ID
ARG APP_DOMAIN
ARG OPENSEARCH_ENABLED="false"
ARG TMDB_READ_API_KEY
ARG CORS_PROXY_URL
ARG DMCA_EMAIL
ARG NORMAL_ROUTER="false"
ARG BACKEND_URL
ARG HAS_ONBOARDING="false"
ARG ONBOARDING_CHROME_EXTENSION_INSTALL_LINK
ARG ONBOARDING_PROXY_INSTALL_LINK
ARG DISALLOWED_IDS
ARG CDN_REPLACEMENTS
ARG TURNSTILE_KEY

ENV VITE_PWA_ENABLED=${PWA_ENABLED}
ENV VITE_GA_ID=${GA_ID}
ENV VITE_APP_DOMAIN=${APP_DOMAIN}
ENV VITE_OPENSEARCH_ENABLED=${OPENSEARCH_ENABLED}
ENV VITE_TMDB_READ_API_KEY=${TMDB_READ_API_KEY}
ENV VITE_CORS_PROXY_URL=${CORS_PROXY_URL}
ENV VITE_DMCA_EMAIL=${DMCA_EMAIL}
ENV VITE_NORMAL_ROUTER=${NORMAL_ROUTER}
ENV VITE_BACKEND_URL=${BACKEND_URL}
ENV VITE_HAS_ONBOARDING=${HAS_ONBOARDING}
ENV VITE_ONBOARDING_CHROME_EXTENSION_INSTALL_LINK=${ONBOARDING_CHROME_EXTENSION_INSTALL_LINK}
ENV VITE_ONBOARDING_PROXY_INSTALL_LINK=${ONBOARDING_PROXY_INSTALL_LINK}
ENV VITE_DISALLOWED_IDS=${DISALLOWED_IDS}
ENV VITE_CDN_REPLACEMENTS=${CDN_REPLACEMENTS}
ENV VITE_TURNSTILE_KEY=${TURNSTILE_KEY}

COPY . ./
RUN pnpm run build

# Install requirements for add-on
RUN \
  apk add --no-cache \
    python3

# Python 3 HTTP Server serves the current working dir
# So let's set it to our add-on persistent data directory.
WORKDIR /data

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

# production environment
# FROM nginx:stable-alpine
# COPY --from=build /app/dist /usr/share/nginx/html
# EXPOSE 80
CMD ["./run.sh"]
