FROM ruby:2.6-stretch

ENV NODE_VERSION "12.16.1"
ENV NODE_ENV=production
ENV RAILS_ENV production
ENV HEROKU true

# Add requirements and install dependencies
RUN set -ex; \
    apt-get update -qq; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https \
        netcat \
        gcc \
        git \
        make \
        openssl \
        postgresql-client \
    ; \
    curl https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz | tar xzf - -C /usr/local --strip-components=1; \
    node --version; \
    npm --version; \
    curl -sS 'https://dl.yarnpkg.com/debian/pubkey.gpg' | apt-key add -; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    apt-get update -q; \
    apt-get install -y --no-install-recommends \
        yarn \
    ; \
    yarn --version; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /private/etc/; \
    touch /private/etc/hosts; \
    echo "127.0.0.1 localhost.ssl" | tee -a /private/etc/hosts

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
    groupadd -f --gid "${APP_GROUP_ID}" "${APP_GROUP}"; \
    useradd --uid "${APP_USER_ID}" --gid "${APP_GROUP_ID}" "${APP_USER}"; \
    mkdir -p "/home/${APP_USER}"; \
    chown -R "${APP_USER}:${APP_GROUP}" "/home/${APP_USER}"

ARG COVID_VERSION=master

ADD --chown=covid:covid https://github.com/lifen-labs/covid/archive/${COVID_VERSION}.tar.gz ./

RUN set -ex; \
    tar -xzf ${COVID_VERSION}.tar.gz; \
    rm -f ${COVID_VERSION}.tar.gz; \
    mv "covid-${COVID_VERSION}" \
        "${APP_PATH}" \
    ; \
    mkdir "${APP_PATH}/var"; \
    chown -R "${APP_USER}:${APP_GROUP}" "${APP_PATH}"

USER ${APP_USER}:${APP_GROUP}

WORKDIR ${APP_PATH}

VOLUME [ "log", "public", "storage", "tmp", "var" ]

RUN set -ex; \
    gem install bundler

RUN set -ex; \
    bundle install \
        --without="development:test" \
        --path vendor/bundle \
        --binstubs vendor/bundle/bin \
        --jobs=4 \
        --deployment \
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
CMD ["bundle", "exec", "rails", "server", "-u", "puma", "-b", "ssl://0.0.0.0:3000?key=var/ssl/server.key&cert=var/ssl/server.crt"]

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
