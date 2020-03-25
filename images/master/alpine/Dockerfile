FROM ruby:2.6-alpine

ENV NODE_VERSION "12.16.1"
ENV NODE_ENV=production
ENV RAILS_ENV production
ENV HEROKU true

# Add requirements and install dependencies
RUN set -ex; \
    apk add --no-cache  \
        build-base \
        curl \
        gcc \
        git \
        libxml2-dev \
        libxslt-dev \
        make \
        openssl \
        postgresql-client \
        postgresql-dev \
        yarn \
    ; \
    curl https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz | tar -xzf - -C /usr/local --strip-components=1; \
    node --version; \
    npm --version; \
    apk add --no-cache  \
        yarn \
    ; \
    yarn --version; \
    rm -rf /var/cache/apk/*

ARG APP_USER=covid
ARG APP_USER_ID=5001
ARG APP_GROUP=covid
ARG APP_GROUP_ID=5001
ARG APP_PATH=/covid

# Follow the principle of least privilege: run as unprivileged user.
#
# Running as non-root enables running this image in platforms like OpenShift
# that do not allow images running as root.
RUN set -ex; \
    addgroup -S --gid "${APP_GROUP_ID}" "${APP_GROUP}"; \
    adduser -D -g '' -u "${APP_USER_ID}" -G "${APP_GROUP}" "${APP_USER}"; \
    mkdir -p "/home/${APP_USER}"; \
    chown -R "${APP_USER}:${APP_GROUP}" "/home/${APP_USER}"

VOLUME [ "log", "public", "storage", "tmp", "var" ]

ARG COVID_VERSION=master

ADD --chown=covid:covid https://github.com/lifen-labs/covid/archive/${COVID_VERSION}.tar.gz ./

RUN set -ex; \
    tar -xzf ${COVID_VERSION}.tar.gz; \
    rm -f ${COVID_VERSION}.tar.gz; \
    mv "covid-${COVID_VERSION}" \
        "${APP_PATH}" \
    ; \
    chown -R "${APP_USER}:${APP_GROUP}" "${APP_PATH}"

USER ${APP_USER}:${APP_GROUP}

WORKDIR ${APP_PATH}

RUN set -ex; \
    gem install bundler

RUN set -ex; \
    bundle install \
        --deployment \
        --path vendor/bundle \
        --no-cache \
        --with="docker opf_plugins" \
        --without="test development" \
        --jobs=8 --retry=3 \
    ; \
    yarn install \
        --no-progress \
        --non-interactive \
    ; \
    rm -rf vendor/bundle/ruby/*/cache; \
    rm -rf vendor/bundle/ruby/*/gems/*/spec; \
    rm -rf vendor/bundle/ruby/*/gems/*/test

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

EXPOSE 3000

# Arguments to label built container
ARG VCS_REF
ARG BUILD_DATE

# Container labels (http://label-schema.org/)
# Container annotations (https://github.com/opencontainers/image-spec)
LABEL maintainer="Monogramm maintainers <opensource at monogramm dot io>" \
      product="Covid" \
      version=$COVID_VERSION \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/Monogramm/docker-covid" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Covid" \
      org.label-schema.description="Web application which aims to facilitate covid-19 patients' self-monitoring at home via forms sent by SMS." \
      org.label-schema.url="https://github.com/lifen-labs/covid" \
      org.label-schema.vendor="Lifen (labs)" \
      org.label-schema.version=$COVID_VERSION \
      org.label-schema.schema-version="1.0" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://github.com/Monogramm/docker-covid" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="Covid" \
      org.opencontainers.image.description="Web application which aims to facilitate covid-19 patients' self-monitoring at home via forms sent by SMS." \
      org.opencontainers.image.url="https://github.com/lifen-labs/covid" \
      org.opencontainers.image.vendor="Lifen (labs)" \
      org.opencontainers.image.version=$COVID_VERSION \
      org.opencontainers.image.authors="Monogramm maintainers <opensource at monogramm dot io>"

RUN set -ex; \
    echo "${COVID_VERSION}" > '.docker-build-version'; \
    echo "${VCS_REF}" > '.docker-build-vcs_ref'; \
    echo "${BUILD_DATE}" > '.docker-build-date'
