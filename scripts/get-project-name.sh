#!/usr/bin/env bash
# Make sure pyproject.toml exists in the current directory
if [ ! -f "pyproject.toml" ]; then
  echo "Error: pyproject.toml not found in the current directory."
  exit 1
fi

# Read name from pyproject.toml
PROJECT_NAME_FIELD="name"
PROJECT_NAME=$(grep "^${PROJECT_NAME_FIELD} =" pyproject.toml | sed -E "s/${PROJECT_NAME_FIELD} = \"(.*)\"/\1/")

if [ -z "${PROJECT_NAME}" ]; then
  echo "Error: 'name' field not found in pyproject.toml."
  exit 1
fi

# if first parameter is json, echo name as json else echo name only
if [ "$1" == "json" ]; then
  echo "{\"name\": \"${PROJECT_NAME}\"}"
else
  echo "${PROJECT_NAME}"
fi
