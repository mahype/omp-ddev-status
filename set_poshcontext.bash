#!/bin/bash
# DDEV status for Oh My Posh prompt
# https://github.com/mahype/omp-ddev-status
#
# This function is called automatically before each prompt render by Oh My Posh.
# It detects DDEV projects and sets environment variables for the prompt segment.
#
# IMPORTANT: This function must be defined AFTER the oh-my-posh init line
# in your .bashrc, because Oh My Posh defines an empty stub that would
# override it otherwise.
#
# Usage: Add the following to your .bashrc AFTER the oh-my-posh init line:
#   source /path/to/set_poshcontext.bash

function set_poshcontext() {
    if [ -f ".ddev/config.yaml" ]; then
        local name
        name=$(grep "^name:" .ddev/config.yaml 2>/dev/null | head -1 | sed 's/^name:[[:space:]]*//' | tr -d "\"'")
        # Fallback: DDEV derives the project name from the directory name
        [ -z "$name" ] && name=$(basename "$PWD")
        if [ -n "$name" ]; then
            local ddev_status
            ddev_status=$(docker inspect --format '{{.State.Status}}' "ddev-${name}-web" 2>/dev/null)
            export POSH_DDEV_NAME="$name"
            case "$ddev_status" in
                running)
                    export POSH_DDEV_STATUS="running"
                    export POSH_DDEV_URL="https://${name}.ddev.site"
                    ;;
                paused)
                    export POSH_DDEV_STATUS="paused"
                    export POSH_DDEV_URL=""
                    ;;
                *)
                    export POSH_DDEV_STATUS="stopped"
                    export POSH_DDEV_URL=""
                    ;;
            esac
            return
        fi
    fi
    unset POSH_DDEV_STATUS POSH_DDEV_NAME POSH_DDEV_URL
}
