# base image
FROM python:3.9-alpine3.13
# define maintainer
LABEL maintainer="ismailonurkaya"
# 
ENV PYTHONUNBUFFERED=1
# copy necessary files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
# set working directory
WORKDIR /app
# expose port
EXPOSE 8000
# set development env
ARG DEV=false
# commands
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
# set PATH
ENV PATH="/py/bin:$PATH"
# switching to django-user, dont use root
USER django-user