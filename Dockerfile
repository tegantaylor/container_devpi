#
FROM python:3.14.0a1

ARG ARG_DEVPI_SERVER_VERSION=5.5.0
ARG ARG_DEVPI_WEB_VERSION=4.0.5
ARG ARG_DEVPI_CLIENT_VERSION=5.2.0
ARG ARG_VIRTUALENV_VERSION=20.0.28

ENV DEVPI_SERVER_VERSION $ARG_DEVPI_SERVER_VERSION
ENV DEVPI_WEB_VERSION $ARG_DEVPI_WEB_VERSION
ENV DEVPI_CLIENT_VERSION $ARG_DEVPI_CLIENT_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="/files/"
ENV PIP_TRUSTED_HOST="127.0.0.1"
ENV VIRTUAL_ENV /env

# create devpi user & group | create files dir for storing pip requirements
RUN addgroup --system --gid 1000 devpi \
    && adduser --disabled-password --system --uid 1000 --home /data --shell /sbin/nologin --gid 1000 devpi \
    && mkdir /files/ 

# copy pip packages required for installing virtualenv and devpi apps into the container
COPY files/. /files/
RUN chmod +x /files/*

# create a virtual env in $VIRTUAL_ENV, ensure it respects pip version
RUN pip install virtualenv==${ARG_VIRTUALENV_VERSION} --no-index --find-links=/files \
 && virtualenv $VIRTUAL_ENV \
 && $VIRTUAL_ENV/bin/pip install pip==$PYTHON_PIP_VERSION
ENV PATH $VIRTUAL_ENV/bin:$PATH

RUN pip install --no-index --find-links=/files \
    "devpi-client==${ARG_DEVPI_CLIENT_VERSION}" \
    "devpi-web==${ARG_DEVPI_WEB_VERSION}" \
    "devpi-server==${ARG_DEVPI_SERVER_VERSION}"

EXPOSE 3141
VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
RUN mkdir /data/server \
  && mkdir /data/client \
  && chown devpi:nogroup /data/server \
  && chown devpi:nogroup /data/client

USER devpi
ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
