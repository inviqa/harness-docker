#!/bin/bash

function task_overlay_apply()
{
    local CODE_OWNER_HOME
    CODE_OWNER_HOME="$(getent passwd "${CODE_OWNER}" | cut -d: -f6)"

    run rsync --exclude='*.twig' --exclude='_twig' -a "${CODE_OWNER_HOME}"/application/overlay/ /app/
}
