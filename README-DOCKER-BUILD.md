# OpenCut Docker Build Automation

This repository contains GitHub Actions workflow for automatically building and pushing OpenCut Docker images to DockerHub.

## Features

- **Automatic Daily Builds**: Checks for new commits in OpenCut repository daily at 2:00 AM UTC
- **Smart Build Trigger**: Only builds when new commits are detected
- **Manual Trigger**: Can be manually triggered with force build option
- **Multi-platform Support**: Builds for both `linux/amd64` and `linux/arm64`
- **Efficient Caching**: Uses GitHub Actions cache for faster builds

## Required Secrets

You need to configure the following secrets in your GitHub repository settings:

### DockerHub Credentials
- `DOCKERHUB_USERNAME`: Your DockerHub username (developer024)
- `DOCKERHUB_TOKEN`: DockerHub access token (not password)

  To create a DockerHub access token:
  1. Log in to DockerHub
  2. Go to Account Settings > Security
  3. Click "New Access Token"
  4. Give it a descriptive name
  5. Copy the token and save it as a GitHub secret

## Setting Up GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Add each required secret:
   - Name: `DOCKERHUB_USERNAME`, Value: `developer024`
   - Name: `DOCKERHUB_TOKEN`, Value: Your DockerHub access token

## Running the Docker Container

When running the Docker container, pass environment variables at runtime:

```bash
docker run -d \
  -e DATABASE_URL="your_database_url" \
  -e BETTER_AUTH_SECRET="your_auth_secret" \
  -e UPSTASH_REDIS_REST_URL="your_redis_url" \
  -e UPSTASH_REDIS_REST_TOKEN="your_redis_token" \
  -e NEXT_PUBLIC_BETTER_AUTH_URL="your_auth_url" \
  -e FREESOUND_CLIENT_ID="your_freesound_client_id" \
  -e FREESOUND_API_KEY="your_freesound_api_key" \
  -p 3000:3000 \
  developer024/opencut:latest
```

Note: Freesound API credentials are optional and should be provided at runtime, not during build.

## Docker Image Tags

The workflow creates the following tags for the Docker image:
- `developer024/opencut:latest` - Always points to the latest build
- `developer024/opencut:main-<sha>` - Branch-based tag with commit SHA

## Manual Trigger

To manually trigger a build:
1. Go to Actions tab in your GitHub repository
2. Select "OpenCut Docker Build and Push" workflow
3. Click "Run workflow"
4. Optionally check "Force build even if no new commits" to build regardless of changes
5. Click "Run workflow"

## Monitoring

The workflow will:
- Check the OpenCut repository for new commits
- Skip build if no new commits (unless force build is enabled)
- Build and push the Docker image if changes are detected
- Update the `.last-built-sha` file to track the last built commit
- Provide a summary in the Actions tab

## Troubleshooting

### Build fails with authentication error
- Verify your DockerHub token is correctly set in secrets
- Ensure the token has push permissions

### Build skips even with new commits
- Check the `.last-built-sha` file
- Use manual trigger with "force build" option

### Out of memory during build
- The workflow uses Docker Buildx with caching
- If issues persist, consider reducing the number of platforms

## Repository Structure

```
.github/workflows/
├── opencut-docker-build.yml  # Main workflow file
.last-built-sha               # Tracks last built commit (auto-updated)
README-DOCKER-BUILD.md        # This file
```