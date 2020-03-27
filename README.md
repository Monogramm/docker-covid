[![License: AGPL v3][uri_license_image]][uri_license]
[![Docs](https://img.shields.io/badge/Docs-Github%20Pages-blue)](https://monogramm.github.io/covid/)
[![Build Status](https://travis-ci.org/Monogramm/docker-covid.svg)](https://travis-ci.org/Monogramm/docker-covid)
[![Docker Automated buid](https://img.shields.io/docker/cloud/build/monogramm/docker-covid.svg)](https://hub.docker.com/r/monogramm/docker-covid/)
[![Docker Pulls](https://img.shields.io/docker/pulls/monogramm/docker-covid.svg)](https://hub.docker.com/r/monogramm/docker-covid/)
[![Docker Version](https://images.microbadger.com/badges/version/monogramm/docker-covid.svg)](https://microbadger.com/images/monogramm/docker-covid)
[![Docker Size](https://images.microbadger.com/badges/image/monogramm/docker-covid.svg)](https://microbadger.com/images/monogramm/docker-covid)
[![GitHub stars](https://img.shields.io/github/stars/Monogramm/docker-covid?style=social)](https://github.com/Monogramm/docker-covid)

# **Covid** Docker image

Docker image for **Covid**.

This image aims to provide the following features:
-   production ready image based on official [ruby](https://hub.docker.com/_/ruby/) docker image
-   using [puma](https://puma.io/) to serve the application
-   available as either debian or alpine variants
-   running as non-root user (user/group name and id based on build arguments)
-   sample Nginx setup
-   automatic wait for database to be ready
-   automatic database setup and migrations
-   automatic admin user creation (email and password based on environment variables)
-   automatic generation of a self signed certifcate for local usage
    *   Note that it's still recommended to mount valid certificates for production

:construction: **This image is still in beta!**

## What is **Covid** ?

Web application which aims to facilitate covid-19 patients' self-monitoring at home via forms sent by SMS.

> [**Covid**](https://github.com/lifen-labs/covid)

## Supported tags

[Dockerhub monogramm/docker-covid](https://hub.docker.com/r/monogramm/docker-covid/)

-   `alpine` `latest`
-   `debian`

## How to run this image ?

1. Clone this project using `git clone https://github.com/Monogramm/docker-covid.git`
1. Replace any default information in the `.env` file by your own (password, Twilio)
1. Run the application by using `docker-compose up -d`
1. Open your browser at _https://localhost:3000/admin/_

For production, it is recommended to generate your own certificates (see `docker-compose.yml`).

# Questions / Issues

If you got any questions or problems using the image, please visit our [Github Repository](https://github.com/Monogramm/docker-covid) and write an issue.

[uri_license]: http://www.gnu.org/licenses/agpl.html

[uri_license_image]: https://img.shields.io/badge/License-AGPL%20v3-blue.svg
