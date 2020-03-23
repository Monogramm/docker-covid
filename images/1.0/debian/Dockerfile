FROM debian
# If based on official images
# FROM lifen-labs/covid:debian

# Add requirements and install application
RUN set -ex; \
    echo '[TODO] ADD INSTALL OPERATIONS'

# Arguments to label built container
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION=1.0.0

# Container labels (http://label-schema.org/)
# Container annotations (https://github.com/opencontainers/image-spec)
LABEL maintainer="Monogramm maintainers <opensource at monogramm dot io>" \
      product="Covid" \
      version=$VERSION \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/Monogramm/docker-covid" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Covid" \
      org.label-schema.description="Web application which aims to facilitate covid-19 patients' self-monitoring at home via forms sent by SMS." \
      org.label-schema.url="https://github.com/lifen-labs/covid" \
      org.label-schema.vendor="Lifen (labs)" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://github.com/Monogramm/docker-covid" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="Covid" \
      org.opencontainers.image.description="Web application which aims to facilitate covid-19 patients' self-monitoring at home via forms sent by SMS." \
      org.opencontainers.image.url="https://github.com/lifen-labs/covid" \
      org.opencontainers.image.vendor="Lifen (labs)" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.authors="Monogramm maintainers <opensource at monogramm dot io>"
