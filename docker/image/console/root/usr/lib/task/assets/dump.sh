#!/bin/bash

function task_assets_dump()
(
    local ASSETS_DIR="${ASSETS_DIR:-tools/assets/development}"
    local DUMP_COMMAND=()

    if [ ! -d "/app/${ASSETS_DIR}" ]; then
        run mkdir -p "/app/${ASSETS_DIR}"
    fi

    if [ "${DB_PLATFORM}" == "mysql" ]; then
        DUMP_COMMAND=(mysqldump -h "${DB_HOST}" -u "${DB_USER}" "-p${DB_PASS}" "${DB_NAME}")
    elif [ "${DB_PLATFORM}"  == "postgres" ]; then
        export PGPASSWORD="$DB_PASS"
        DUMP_COMMAND=(pg_dump -h "${DB_HOST}" -U "${DB_USER}" "${DB_NAME}")
    elif [ -n "${DB_PLATFORM}" ]; then
        echo "invalid database type" >&2
        exit 1
    fi

    run "$(printf ' %q' "${DUMP_COMMAND[@]}") | gzip > '/app/${ASSETS_DIR}/${DB_NAME}.sql.gz'"
)
