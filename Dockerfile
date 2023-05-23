ARG TOOLKIT_VERSION=1.0.3
ARG PYTHON_VERSION=3.11
FROM 221120163160.dkr.ecr.ap-southeast-1.amazonaws.com/python:py$PYTHON_VERSION-$TOOLKIT_VERSION-toolkit-base as base
FROM 221120163160.dkr.ecr.ap-southeast-1.amazonaws.com/python:py$PYTHON_VERSION-$TOOLKIT_VERSION-toolkit-builder as builder

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

ARG ARTIFACT_USERNAME=aws
ARG ARTIFACT_PASSWORD

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN /scripts/install-dependencies.sh

# `production` image used for workloads
FROM base

RUN mkdir -p /opt/dagster/dagster_home/storage && chown app:app -R /opt/dagster

USER app
WORKDIR /app

COPY --from=builder $PYSETUP_PATH $PYSETUP_PATH
COPY --chown=app:app . /app/

ENTRYPOINT ["/usr/bin/dumb-init"]
