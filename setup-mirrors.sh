#!/usr/bin/env bash
set -e
shopt -s lastpipe
export IFS=$'\n'

cd -- "$(dirname -- "$0")"
[ ! -d /var/www/cache ] && mkdir --parents /var/www/cache

declare -A sections
current_section=""

function stripConfigFile() {
    sed \
        -e '/^$/d' \
        -e '/^ *#/d'
}

stripConfigFile < /etc/pacman.conf |\
while read -r line; do
    if grep -q '^\[.*\]$' <<< "$line"; then
        current_section="${line:1:-1}"
        sections["$current_section"]=""
        echo found section "$current_section" >&2
        continue
    fi
    if [ -n "$current_section" ]; then
        sections["$current_section"]+="$line"$'\n'
    fi
done
echo found "${#sections[@]}" sections >&2

function isConfAssignment() {
    local name="$1"
    [ -z "$name" ] && return 1
    grep --ignore-case --quiet '^'"$name"' *= *'
}

function getConfAssignment() {
    local name="$1"
    [ -z "$name" ] && return 1
    sed 's/'"$name"' *= *\(.*\)$/\1/i'
}

declare -g -x PORT=8000
function processRepoSection() {
    local repo="$1"
    [ -z "$repo" ] && return 1
    declare -l -a lines
    mapfile -t lines
    for line in "${lines[@]}"; do
        if isConfAssignment Include <<< "$line"; then
            local file
            file=$(getConfAssignment Include <<< "$line")
            [ ! -f "$file" ] && echo included file "$file" does not exist >&2 && continue
            stripConfigFile < "$file" | processRepoSection "$repo"
            continue
        fi
        if isConfAssignment Server <<< "$line"; then
            declare -x REPO_URL=""
            REPO_URL=$(getConfAssignment Server <<< "$line")
            # shellcheck disable=SC2016
            envsubst '$REPO_URL,$PORT' < mirror.template
            PORT=$((PORT + 1))
            continue
        fi
        echo ignoring config line "$line" >&2
    done
}

function processRepo() {
    local repo="$1"
    [ -z "$repo" ] && return 1
    local startport="$PORT"
    processRepoSection "$repo"
    local endport="$PORT"
    echo "upstream $repo {"
    for port in $(seq "$startport" "$((endport - 1))"); do
        echo "    server 127.0.0.1:$port;"
    done
    echo "}"
}

# Process each section and its lines
for section in "${!sections[@]}"; do
    [ "$section" = options ] && continue #skip general options section
    echo "Processing repo: $section"
    stripConfigFile  <<< "${sections[$section]}" | processRepo "$section" \
    > /etc/nginx/conf.d/upstream-"$section".conf
done
