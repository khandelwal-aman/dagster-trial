#!/usr/bin/env bash
set -e
aws sts get-caller-identity
make test

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 221120163160.dkr.ecr.ap-southeast-1.amazonaws.com

make build-docker
terragrunt plan --terragrunt-working-dir deployment/environments/ml/development -lock=false
./scripts/conditional-push.sh
