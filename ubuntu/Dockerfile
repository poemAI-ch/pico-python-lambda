ARG PYTHON_VERSION=3.12
ARG BASE_IMAGE_VERSION=22.04

# Base AWS Lambda image (Amazon Lambda runtime)
FROM public.ecr.aws/lambda/python:${PYTHON_VERSION} AS aws_lambda_base

# Stage 1: Ubuntu base Python environment
FROM ubuntu:${BASE_IMAGE_VERSION} AS python_lambda_base

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3=${PYTHON_VERSION}* \
    python3-venv \
    python3-pip \
    build-essential \
    libssl-dev \
    libffi-dev \
    cmake \
    curl \
    bash \
    binutils \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Upgrade pip and install AWS Lambda Runtime Interface Client (RIC)
RUN pip install --upgrade pip && pip install awslambdaric

# Stage 2: Final image using official Python base image
FROM python:${PYTHON_VERSION}-slim-bullseye AS final

# Install runtime components for Lambda runtime emulator
RUN apt-get update && apt-get install -y binutils && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from the previous stage
COPY --from=python_lambda_base /venv /venv

# Copy AWS Lambda Runtime Interface Emulator from the AWS base image
COPY --from=aws_lambda_base /usr/local/bin/aws-lambda-rie /usr/local/bin/aws-lambda-rie

# Define the entry point
ENTRYPOINT [ "/usr/local/bin/aws-lambda-rie", "python3", "-m", "awslambdaric" ]
