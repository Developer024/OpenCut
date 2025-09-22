FROM oven/bun:alpine AS base

# Install dependencies and build the application
FROM base AS builder

WORKDIR /app

# Build-time arguments are optional, will use defaults if not provided
ARG FREESOUND_CLIENT_ID=""
ARG FREESOUND_API_KEY=""

# Copy package files from submodule
COPY opencut/package.json package.json
COPY opencut/bun.lock bun.lock
COPY opencut/turbo.json turbo.json

COPY opencut/apps/web/package.json apps/web/package.json
COPY opencut/packages/db/package.json packages/db/package.json
COPY opencut/packages/auth/package.json packages/auth/package.json

RUN bun install

# Copy source files from submodule
COPY opencut/apps/web/ apps/web/
COPY opencut/packages/db/ packages/db/
COPY opencut/packages/auth/ packages/auth/

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# Set all build-time environment variables
# Default values for build process (will be overridden at runtime)
ENV DATABASE_URL="postgresql://opencut:opencutthegoat@localhost:5432/opencut"
ENV BETTER_AUTH_SECRET="build-time-secret"
ENV UPSTASH_REDIS_REST_URL="http://localhost:8079"
ENV UPSTASH_REDIS_REST_TOKEN="example_token"
ENV NEXT_PUBLIC_BETTER_AUTH_URL="http://localhost:3000"

# Set Freesound API variables (optional, can be overridden at runtime)
ENV FREESOUND_CLIENT_ID=${FREESOUND_CLIENT_ID:-"default_client_id"}
ENV FREESOUND_API_KEY=${FREESOUND_API_KEY:-"default_api_key"}

# Set Cloudflare R2 variables with defaults for build
ENV CLOUDFLARE_ACCOUNT_ID="default_account_id"
ENV R2_ACCESS_KEY_ID="default_access_key"
ENV R2_SECRET_ACCESS_KEY="default_secret_key"
ENV R2_BUCKET_NAME="default_bucket"

# Set Modal transcription URL with default
ENV MODAL_TRANSCRIPTION_URL="http://localhost:8080/transcribe"

WORKDIR /app/apps/web
RUN bun run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/apps/web/public ./apps/web/public
COPY --from=builder --chown=nextjs:nodejs /app/apps/web/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/apps/web/.next/static ./apps/web/.next/static

RUN chown nextjs:nodejs apps

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["bun", "apps/web/server.js"]