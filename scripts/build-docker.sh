#!/usr/bin/env bash
set -e
# Cache the CodeArtifact token locally
mkdir -p .artifact
TOKEN_FILE=.artifact/token

find .artifact -name token -type f -mmin +600 -delete

if [ ! -f "$TOKEN_FILE" ]; then
  echo "AWS CodeArtifact token expired. Acquiring new token."
  aws codeartifact get-authorization-token --domain canopy --region ap-southeast-1 --domain-owner 221120163160 --query authorizationToken --output text > $TOKEN_FILE
fi

# Read name from pyproject.toml
PROJECT_NAME=$(./scripts/get-project-name.sh)
echo "Using project name: $PROJECT_NAME"

IMAGE_TAG_PREFIX=${IMAGE_TAG_PREFIX:-"$PROJECT_NAME:build"}
ARTIFACT_PASSWORD=$(cat $TOKEN_FILE)

echo "Logging into ECR"
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 221120163160.dkr.ecr.ap-southeast-1.amazonaws.com

echo "Building docker image"
docker build -t "${IMAGE_TAG_PREFIX}" --build-arg ARTIFACT_PASSWORD="${ARTIFACT_PASSWORD}" .
