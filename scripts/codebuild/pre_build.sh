#!/usr/bin/env bash
set -e

# shellcheck disable=SC2086
clamscan ${CLAMAV_SCAN_ARGS} "$(poetry env info --path)"

# shellcheck disable=SC2086
clamscan ${CLAMAV_SCAN_ARGS} .
