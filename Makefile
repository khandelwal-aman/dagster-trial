# Minimal makefile for Sphinx documentation
#
DOCKER_REPO   ?= 221120163160.dkr.ecr.ap-southeast-1.amazonaws.com/canopy-pipeline
VERSION		  ?= dev

artifact-login:
	@poetry config http-basic.artifact aws $(shell aws codeartifact get-authorization-token --domain canopy --region ap-southeast-1 --domain-owner 221120163160 --query authorizationToken --output text)

fix:
	poetry run black --config pyproject.toml .
	poetry run pre-commit run --all-files

lint:
	poetry run black --config pyproject.toml --check .
	poetry run pylint --verbose --rcfile=.pylintrc canopy_pipeline canopy_pipeline_tests scripts
	poetry run bandit -r canopy_pipeline -c .bandit.yml -b .bandit.baseline
	poetry run pytype --no-cache --config pytype.cfg

pytest:
	rm -rf .test_reports/*
	poetry run pytest -n auto --cov-report term:skip-covered --cov-report xml:.test_reports/cov.xml --junitxml=.test_reports/pytest_report.xml --cov=identity_server --cov-config=.coveragerc tests -vvv

test: lint # pytest
	# poetry run coverage html -d .test_reports/cov_html
	@echo "Tests complete ✔︎"

init-template:
	./scripts/init-template.sh

setup: install
	poetry run pre-commit install
	poetry run pre-commit run --all-files

install: artifact-login
	poetry install

dev:
	dagster dev

build-docker:
	./scripts/build-docker.sh

deploy-development:
	@echo "Deploying to Development"
	terragrunt run-all apply --terragrunt-strict-include --terragrunt-include-dir 'deployment/environments/*/development' --terragrunt-parallelism 1 --terragrunt-non-interactive

deploy-testing:
	@echo "Deploying to Testing"
	terragrunt run-all apply --terragrunt-strict-include --terragrunt-include-dir 'deployment/environments/*/testing' --terragrunt-parallelism 1 --terragrunt-non-interactive

deploy-staging:
	@echo "Deploying to Staging"
	terragrunt run-all apply --terragrunt-strict-include --terragrunt-include-dir 'deployment/environments/*/staging' --terragrunt-parallelism 1 --terragrunt-non-interactive

deploy-production:
	@echo "Deploying to Production"
	terragrunt run-all apply --terragrunt-strict-include --terragrunt-include-dir 'deployment/environments/*/production' --terragrunt-parallelism 1 --terragrunt-non-interactive
