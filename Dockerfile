FROM oven/bun:alpine AS base

# Install dependencies and build the application
FROM base AS builder

WORKDIR /app

# Build-time arguments for all required environment variables
ARG FREESOUND_CLIENT_ID
ARG FREESOUND_API_KEY
ARG CLOUDFLARE_ACCOUNT_ID
ARG R2_ACCESS_KEY_ID
ARG R2_SECRET_ACCESS_KEY
ARG R2_BUCKET_NAME
ARG MODAL_TRANSCRIPTION_URL

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

# Set Freesound API variables
ENV FREESOUND_CLIENT_ID=$FREESOUND_CLIENT_ID
ENV FREESOUND_API_KEY=$FREESOUND_API_KEY

# Set Cloudflare R2 variables
ENV CLOUDFLARE_ACCOUNT_ID=$CLOUDFLARE_ACCOUNT_ID
ENV R2_ACCESS_KEY_ID=$R2_ACCESS_KEY_ID
ENV R2_SECRET_ACCESS_KEY=$R2_SECRET_ACCESS_KEY
ENV R2_BUCKET_NAME=$R2_BUCKET_NAME

# Set Modal transcription URL
ENV MODAL_TRANSCRIPTION_URL=$MODAL_TRANSCRIPTION_URL

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