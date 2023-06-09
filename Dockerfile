
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
COPY ./scripts /scripts
COPY ./app /app

# Default directory that all commands will be running from
# when we run commands on our Docker image. Put location
# where our Django project will be sinked to.
WORKDIR /app

# Expose this port from the container to the machine running the container
EXPOSE 8000

# Define build arguments
ARG DEV=false

USER root

# Single run command to keep one image layer for simplicity
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache pcre pcre-dev && \
    # install  postgresql client for psychopg2 \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    # set virtual dependency package and make it temporary to delete it after psychopg2 is installed
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    # remove temporary dependencies for building -> keep the image as small as possible
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    chown -R django-user:django-user /vol/web/media && \
    chmod -R 755 /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol/web/static && \
    chmod -R 755 /vol/web/static && \
    chmod -R +x /scripts

# Update the environment variable
ENV PATH="/scripts:/py/bin:$PATH"

# Change the user from 'root' to 'django-user'
USER django-user

CMD ["run.sh"]
