# OpenCut Docker Build

Automated Docker build for OpenCut application with submodule auto-update support.

## Features

- **Auto-update submodule**: Automatically updates OpenCut submodule to latest version
- **Triggered on main branch push**: Builds only when pushing to main branch
- **Manual trigger support**: Can be triggered manually with force build option
- **Multi-platform builds**: Supports linux/amd64, linux/arm64, linux/arm/v7, linux/386
- **Default environment variables**: Uses safe defaults, can be overridden at runtime

## Required GitHub Secrets

Configure these secrets in your GitHub repository (Settings > Secrets and variables > Actions):

### DockerHub
- `DOCKERHUB_USERNAME`: Your DockerHub username
- `DOCKERHUB_TOKEN`: Your DockerHub access token

## How it Works

1. **On push to main**: The workflow automatically triggers
2. **Submodule update**: Checks and updates the OpenCut submodule to latest version
3. **Build Docker image**: Builds using the custom Dockerfile with all required environment variables
4. **Push to DockerHub**: Pushes the image with appropriate tags

## Docker Image Tags

- `{username}/opencut:latest` - Always points to the latest build
- `{username}/opencut:main-{sha}` - Git commit SHA tag

## Running the Container

```bash
docker run -d \
  -e DATABASE_URL="your_database_url" \
  -e BETTER_AUTH_SECRET="your_auth_secret" \
  -e UPSTASH_REDIS_REST_URL="your_redis_url" \
  -e UPSTASH_REDIS_REST_TOKEN="your_redis_token" \
  -e NEXT_PUBLIC_BETTER_AUTH_URL="your_auth_url" \
  -e FREESOUND_CLIENT_ID="your_client_id" \
  -e FREESOUND_API_KEY="your_api_key" \
  -e CLOUDFLARE_ACCOUNT_ID="your_account_id" \
  -e R2_ACCESS_KEY_ID="your_r2_key" \
  -e R2_SECRET_ACCESS_KEY="your_r2_secret" \
  -e R2_BUCKET_NAME="your_bucket" \
  -e MODAL_TRANSCRIPTION_URL="your_modal_url" \
  -p 3000:3000 \
  your-username/opencut:latest
```

## Manual Trigger

1. Go to Actions tab in GitHub
2. Select "Docker Build and Push" workflow
3. Click "Run workflow"
4. Optionally check "Force build even if no changes"
5. Click "Run workflow"

## Submodule Management

The workflow automatically:
- Updates the OpenCut submodule to the latest commit from its main branch
- Commits the update if there are changes
- Builds the Docker image with the updated code

To manually update the submodule locally:
```bash
git submodule update --remote --merge opencut
git add opencut
git commit -m "Update OpenCut submodule"
git push
```

## Workflow File

- `.github/workflows/docker-build.yml` - Main workflow with auto-update

## Project Structure

```
.
├── Dockerfile                    # Custom Dockerfile with default values
├── opencut/                     # OpenCut submodule
├── .gitmodules                  # Submodule configuration
├── .github/
│   └── workflows/
│       └── docker-build.yml    # Main workflow
└── README.md                    # This file
```