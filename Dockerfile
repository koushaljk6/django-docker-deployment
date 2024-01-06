FROM python:3.9-alpine3.13
LABEL maintainer="londonappdeveloper.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /requirements.txt
COPY ./app /app

WORKDIR /app
EXPOSE 8000

# we are installing these packages(Line 23-25) to add the # postgres driver to our django application
# We have added 2 dependencies here, 1: Line 23 the postgresql-client is needed after the postgres drive is installed,
# so this installs the client and everything that the postgres sql driver needs in order to connect to the postgres server,
#so we install that here and we're going to leave that installed in the docker image

#2nd dependency (line 24-25): we have these temp dependencies so these are only needed in order to install the driver
#Line 25 is used to install the psycopg2 mentioned in requirements.txt file this is the only way to install it using alpine tag
#so once we've installed the driver we can then remove these dependencies to keep the image lightweight that's why using line 27

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \                  
    apk add --update --no-cache postgresql-client && \   
    apk add --update --no-cache --virtual .tmp-deps \      
        build-base postgresql-dev musl-dev && \          
    /py/bin/pip install -r /requirements.txt && \
    apk del .tmp-deps && \
    adduser --disabled-password --no-create-home app && \
    mkdir -p /vol/web/static && \
    mkdir -p /vol/web/media && \
    # the below line will  give all permissionans to respective app user before this root user was having permissions
    #the r basically says recursive so any sub directory there assign it to the app user
    chown -R app:app /vol && \
    #the below line will ensure that the owner has access to read write and change anything in those directories
    chmod -R 755 /vol               

ENV PATH="/py/bin:$PATH"

USER app