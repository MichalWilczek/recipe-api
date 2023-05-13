
# Name of the Python image and its the specific version
# alpine -> lightweight and efficient version for Docker
FROM python:3.9-alpine3.13
LABEL maintainer="MichalWilczek"

# Recommended when running in Docker
# We don't want to buffer the output
ENV PYTHONUNBUFFERED 1

# Copy the necessary files in the docker image
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Default directory that all commands will be running from
# when we run commands on our Docker image. Put location
# where our Django project will be sinked to.
WORKDIR /app

# Expose this port from the container to the machine running the container
EXPOSE 8000

# Define build arguments
ARG DEV=false

# Single run command to keep one image layer for simplicity
RUN python -m venv /py && \
  /py/bin/pip install --upgrade pip && \
  /py/bin/pip install -r /tmp/requirements.txt && \
  if [ $DEV = "true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt; \
  fi && \
  rm -rf /tmp && \
  adduser \
    --disabled-password \
    --no-create-home \
    django-user

# Update the environment variable
ENV PATH="/py/bin:$PATH"

# Change the user from 'root' to 'django-user'
#USER django-user
