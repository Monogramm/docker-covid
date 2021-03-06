#!/bin/sh
set -e

###########################################################
# Functions


log() {
    MESSAGE=$1

    echo "[$0] [$(date +%Y-%m-%dT%H:%M:%S)] ${MESSAGE}"
}

# init flag file
init_file() {
    FILE=${1}
    if [ -z "${FILE}" ]; then
        log "Missing name docker init file!"
        exit 1
    fi

    CONTENT=${2:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}

    echo "$CONTENT" \
        > "${FILE}"
}

# wait for service to be reachable
wait_for_service() {
    WAIT_FOR_ADDR=${1}
    if [ -z "${WAIT_FOR_ADDR}" ]; then
        log "Missing service's address to wait for!"
        exit 1
    fi

    WAIT_FOR_PORT=${2}
    if [ -z "${WAIT_FOR_PORT}" ]; then
        log "Missing service's port to wait for!"
        exit 1
    fi

    WAIT_TIME=0
    WAIT_STEP=${3:-10}
    WAIT_TIMEOUT=${4:--1}

    while ! nc -z "${WAIT_FOR_ADDR}" "${WAIT_FOR_PORT}" ; do
        if [ "${WAIT_TIMEOUT}" -gt 0 ] && [ "${WAIT_TIME}" -gt "${WAIT_TIMEOUT}" ]; then
            log "Service '${WAIT_FOR_ADDR}:${WAIT_FOR_PORT}' was not available on time!"
            exit 1
        fi

        log "Waiting service '${WAIT_FOR_ADDR}:${WAIT_FOR_PORT}'..."
        sleep "${WAIT_STEP}"
        WAIT_TIME=$(( WAIT_TIME + WAIT_STEP ))
    done
    log "Service '${WAIT_FOR_ADDR}:${WAIT_FOR_PORT}' available."
}

wait_for_services() {
    WAIT_FOR_HOSTS=${1}
    if [ -z "${WAIT_FOR_HOSTS}" ]; then
        log "Missing services to wait for!"
        exit 1
    fi

    for H in ${WAIT_FOR_HOSTS}; do
        WAIT_FOR_ADDR=$(echo "${H}" | cut -d: -f1)
        WAIT_FOR_PORT=$(echo "${H}" | cut -d: -f2)

        wait_for_service "${WAIT_FOR_ADDR}" "${WAIT_FOR_PORT}" "${WAIT_STEP}" "${WAIT_TIMEOUT}"
    done

}

# version_greater A B returns whether A > B
version_greater() {
	[ "$(printf '%s\n' "$@" | sort -t '.' -n -k1,1 -k2,2 -k3,3 -k4,4 | head -n 1)" != "$1" ]
}

# date_greater A B returns whether A > B
date_greater() {
    [ $(date -u -d "$1" -D "%Y-%m-%dT%H:%M:%SZ" +%s) -gt $(date -u -d "$2" -D "%Y-%m-%dT%H:%M:%SZ" +%s) ];
}

###########################################################
# Runtime

if [ -z "${DATABASE_URL}" ]; then
    log "Initializing App database URL..."

    if [ ! "${COVID_DB_TYPE}" = "sqlite" ]; then
        if [ -n "${COVID_DB_PASSWORD}" ]; then
            export DATABASE_URL="${COVID_DB_TYPE}://${COVID_DB_USER}:${COVID_DB_PASSWORD}@${COVID_DB_HOST}:${COVID_DB_PORT}/${COVID_DB_NAME}?serverVersion=${COVID_DB_VERSION}${COVID_DB_OPTIONS}"
        else
            export DATABASE_URL="${COVID_DB_TYPE}://${COVID_DB_HOST}:${COVID_DB_PORT}/${COVID_DB_NAME}?serverVersion=${COVID_DB_VERSION}${COVID_DB_OPTIONS}"
        fi
    else
        export DATABASE_URL="${COVID_DB_TYPE:-sqlite}://%kernel.project_dir%/var/${COVID_DB_NAME:-alis}"
    fi

    log "App database URL initialized"
fi

if [ -n "${COVID_DB_HOST}" ] && [ -n "${COVID_DB_PORT}" ]; then
    # Wait for service to be ready
    wait_for_services "${COVID_DB_HOST}:${COVID_DB_PORT}"

    if [ -n "${COVID_DB_TYPE}" ]; then
        # Check postgresql is accepting connections
        pg_isready --host="${COVID_DB_HOST}" --port="${COVID_DB_PORT}"
    fi
fi

if [ -n "${DATABASE_URL}" ]; then
    log "Checking application's database status..."

    if bundle exec rails db:version | grep 'Current version: 0'; then
        log "Executing application's database setup..."
        bundle exec rails db:setup
        log "Application's database setup applied."
        bundle exec rails db:version
    else
        log "Checking application's migrations status..."
        bundle exec rails db:migrate:status

        # Execute migrations if needed
        if bundle exec rails db:migrate:status | grep '^down '; then
            log "Executing application's database migrations..."
            bundle exec rails db:migrate
            log "Application's database migrations applied."
            bundle exec rails db:migrate:status
        fi

    fi

    # Generate default admin account if never done before and vars defined
    if [ ! -f 'var/.docker-init-admin' ] && [ -n "${COVID_ADMIN_EMAIL}" ] && [ -n "${COVID_ADMIN_PASSWORD}" ]; then
        log "Generating default admin account '${COVID_ADMIN_EMAIL}'..."

        # Send command to rails console
        echo "AdminUser.create!(email: '${COVID_ADMIN_EMAIL}', password: '${COVID_ADMIN_PASSWORD}', password_confirmation: '${COVID_ADMIN_PASSWORD}')" \
            | bundle exec rails c
        init_file 'var/.docker-init-admin'

        log "Default admin account generated."
    fi
fi

if [ ! -d  'var/ssl' ]; then
    log "No SSL certificates found. You should mount your own certificates at $(pwd)/var/ssl/server.key and $(pwd)/var/ssl/server.crt."

    log "Generating default self signed certificates..."

    mkdir -p 'var/ssl';

    # Generate a random password
    </dev/urandom tr -dc 'A-Za-z0-9+\-*_' | head -c 64 > 'var/ssl/.ssl_passout';

    # See reference at https://gist.github.com/tadast/9932075
    # Create your private key (any password will do, we remove it below)
    openssl genrsa \
        -aes128 \
        -out var/ssl/server.orig.key \
        -passout file:var/ssl/.ssl_passout \
        2048 \
    ;

    # Remove the password
    openssl rsa \
        -passin file:var/ssl/.ssl_passout \
        -in var/ssl/server.orig.key \
        -out var/ssl/server.key \
    ;

    # Generate the csr (Certificate signing request)
    # Uses localhost.ssl as the common name to keep browsers happy 
    # (has to do with non internal domain names ... which sadly can be
    # avoided with a domain name with a "." in the middle of it somewhere)
    openssl req \
        -new \
        -passin file:var/ssl/.ssl_passout \
        -key var/ssl/server.key \
        -out var/ssl/server.csr \
        -subj "/C=${SSL_COUNTRY:-FR}/ST=Unknown/L=Unknown/O=Unknown/OU=Unknown/CN=localhost.ssl" \
    ;

    # Generate self signed ssl certificate 
    openssl x509 \
        -req \
        -days 365 \
        -in var/ssl/server.csr \
        -signkey var/ssl/server.key \
        -out var/ssl/server.crt \
    ;

    log "Default self signed certificates generated."
fi

if [ ! -d 'var/.docker-init-assets' ]; then
    log "Precompiling assets..."
    
    bundle exec rake assets:precompile;
    bundle exec rake assets:clean;
    init_file 'var/.docker-init-assets'

    log "Assets precompiled."
fi


log "Executing App command..."
exec "$@"
