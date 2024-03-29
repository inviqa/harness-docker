#!/bin/bash

setup_app_volume_permissions()
{
    case "$STRATEGY" in
        "host-linux-normal")
            usermod  -u "$(stat -c '%u' /app)" "${CODE_OWNER}"
            groupmod -g "$(stat -c '%g' /app)" "${CODE_OWNER_GROUP}"
            ;;
        "host-osx-normal")
            usermod  -u 1000 "${CODE_OWNER}"
            groupmod -g 1000 "${CODE_OWNER_GROUP}"
            ;;
        "host-osx-dockersync")
            usermod  -u 1000 "${CODE_OWNER}"
            groupmod -g 1000 "${CODE_OWNER_GROUP}"
            ;;
        *)
            echo "error: unsupported /app volume permission strategy '$STRATEGY'" >&2
            exit 1
    esac

    chown "${CODE_OWNER}:${CODE_OWNER_GROUP}" /app
}

resolve_volume_mount_strategy()
{
    if [ "${HOST_OS_FAMILY}" = "linux" ]; then
        STRATEGY="host-linux-normal"
    elif [ "${HOST_OS_FAMILY}" = "darwin" ]; then
        if (mount | grep "/app type fuse.osxfs") > /dev/null 2>&1; then
            STRATEGY="host-osx-normal"
        elif (mount | grep "/app type fuse.grpcfuse") > /dev/null 2>&1; then
            STRATEGY="host-osx-normal"
        elif (mount | grep "/app type virtiofs") > /dev/null 2>&1; then # virtiofs (Docker Desktop < 4.15)
            STRATEGY="host-osx-normal"
        elif (mount | grep "/app type fakeowner") > /dev/null 2>&1; then # virtiofs (Docker Desktop >= 4.15)
            STRATEGY="host-osx-normal"
        elif (mount | grep "/app type ext4") > /dev/null 2>&1; then
            STRATEGY="host-osx-dockersync"
        elif (mount | grep "/app type btrfs") > /dev/null 2>&1; then
            STRATEGY="host-linux-normal"
        elif (mount | grep "/app type") > /dev/null 2>&1; then
            echo "error: unsupported mount type for '$(mount | grep "/app type")'" >&2
            exit 1
        else
            echo "error: mount for /app not found" >&2
            exit 1
        fi
    else
        echo "error: unsupported host OS family '$HOST_OS_FAMILY'" >&2
        exit 1
    fi
}

bootstrap()
{
    resolve_volume_mount_strategy
    setup_app_volume_permissions
}

bootstrap

source /entrypoint.sh "$@"
