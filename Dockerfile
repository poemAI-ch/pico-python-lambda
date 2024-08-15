ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.19

FROM public.ecr.aws/lambda/python:${PYTHON_VERSION} AS aws_lambda_base


FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS python_lambda_base

# Install necessary packages
RUN apk update && apk add --no-cache autoconf automake bash binutils cmake g++ gcc libtool make elfutils-dev

# Create virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Upgrade pip and install AWS Lambda RIC
RUN pip install --upgrade pip && pip install awslambdaric

# Final image
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS final

# awslambdaric requires binutils
RUN apk update && apk add binutils

# Set up virtual environment
RUN python3 -m venv /venv 
ENV PATH="/venv/bin:$PATH"

# Copy virtual environment from previous stage
COPY --from=python_lambda_base /venv /venv

COPY --from=aws_lambda_base /usr/local/bin/aws-lambda-rie /usr/local/bin/aws-lambda-rie
