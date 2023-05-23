#!/usr/bin/env bash
wget -O load-codebuild-env.sh https://goo.gl/kvyWsa && chmod +x load-codebuild-env.sh && . ./load-codebuild-env.sh

export ALLOWED_BRANCHES='development testing staging production'
export CURRENT_BRANCH="$CODEBUILD_FINAL_BRANCH"

deploy() {
    make "deploy-$CURRENT_BRANCH"
}

[[ ${ALLOWED_BRANCHES} =~ (^|[[:space:]])$CURRENT_BRANCH($|[[:space:]]) ]] && deploy || echo "Skip Deploy as $CURRENT_BRANCH not in $ALLOWED_BRANCHES"
