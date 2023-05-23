#!/bin/bash

# Auto detect repo name
repo_name=$(git ls-remote --get-url | xargs basename -s .git)
echo "Detected repository name: $repo_name"

# Confirm repo name with user and allow override
read -p "Press Enter to confirm, or type a new name and press Enter: " user_input
if [ ! -z "$user_input" ]
then
  repo_name=$user_input
fi
echo "Selected repository name: $repo_name"

# Make sure pyproject.toml file exists in current directory
if [ ! -f "pyproject.toml" ]
then
  echo "Error: pyproject.toml not found in the current directory."
  exit 1
fi

# Edit pyproject.toml and set repo name
sed -i.bak "s/^name = .*/name = \"$repo_name\"/" pyproject.toml

if [ $? -eq 0 ]
then
  echo "pyproject.toml has been successfully updated."
  # Remove backup file
  rm pyproject.toml.bak
else
  echo "Error: Could not update pyproject.toml."
  exit 1
fi

# Replace canopy-pipeline-template in root.hcl with repo_name
TERRAGRUNT_ROOT_FILE="deployment/environments/root.hcl"
if [ ! -f "$TERRAGRUNT_ROOT_FILE" ]
then
  echo "Error: $TERRAGRUNT_ROOT_FILE not found."
  exit 1
fi

sed -i.bak "s/canopy-pipeline-template/$repo_name/" $TERRAGRUNT_ROOT_FILE

if [ $? -eq 0 ]
then
  echo "$TERRAGRUNT_ROOT_FILE has been successfully updated."
  # Remove backup file
  rm ${TERRAGRUNT_ROOT_FILE}.bak
else
  echo "Error: Could not update $TERRAGRUNT_ROOT_FILE."
  exit 1
fi
