#!/bin/bash

# Abort script at first error
set -o errexit

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

BOX_NAME="lostsnow/dev-box"
BOX_PROVIDER="virtualbox"
API_URL=https://app.vagrantup.com/api/v1/box

# Flag parser
usage() {
    case "$1" in
        create | package | upload | release )
            echo -e "Usage: $( basename $0 ) $1 [arg...]"
            echo
            echo -e "Options:"

            if [ $1 == "create" ] || [ $1 == "upload" ] || [ $1 == "release" ]; then
                echo -e "  -v <version>          box version"
            fi

            if [ $1 == "create" ] || [ $1 == "upload" ]; then
                echo -e "  -p <provider>         box provider, default: virtualbox"
            fi

            echo -e "  -n <name>             box name, default: lostsnow/dev-box"

            echo
            exit 1
            ;;
        * )
            echo -e "Usage: $( basename $0 ) <command> [arg...]"
            echo
            echo -e "Commands:"
            echo -e "  help <command>   print command help message"
            echo -e "  create           create box version and provider"
            echo -e "  package          package box"
            echo -e "  upload           upload box file"
            echo -e "  release          release box"
            echo
            echo -e "Options:"
            echo -e "  --help           give this help list"
            echo
            exit 1
            ;;
    esac
}

catch_all () {
    [[ ! -z "$1" ]] && warning "$1: command not found"
    exit 1
}

function_exists () {
    type $1 2> /dev/null | grep -q 'function'
}

cecho () {
    local MSG=$1
    local COLOR=$2
    local PREFIX=
    local SUFFIX="\e[0m"
    case "$COLOR" in
        red)
            PREFIX="\e[0;31m"
            ;;
        green)
            PREFIX="\e[0;32m"
            ;;
        brown)
            PREFIX="\e[0;33m"
            ;;
        purple)
            PREFIX="\e[0;35m"
            ;;
        *)
            PREFIX=""
            SUFFIX=""
        ;;
    esac
    MSG="$PREFIX$MSG$SUFFIX"
    set builtin
    echo -ne "$MSG"
}
ncecho () {
    cecho "$@"
    echo
}

now () {
    cecho `date "+%Y/%m/%d:%H:%M:%S"` $1;
}

fatal () {
    ncecho "[FATAL] $1" "red" && exit 1
}
error () {
    ncecho "[ERROR] $1" red
}
success () {
    ncecho "[SUCCESS] $1" green
}
info () {
    ncecho "[INFO] $1" purple
}

json_val() {
    temp=`echo $1 | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2`
    echo ${temp##*|}
}

# Checks for an Vagrant cloud API Error
check_error() {
    if  [[ $1 == '{"errors":'* ]] ;
    then
        error "$*"
        exit 1
    fi
}

simplify_name() {
    local name=$1
    echo ${name//\//\-}
}

run() {
    if function_exists _$(basename $0) ; then
        CMD=$(basename $0)
    elif function_exists _$1 ; then
        CMD=$1
        shift
    else
        catch_all $@
    fi

    while true; do
        case "$1" in
            -v )
                BOX_VERSION="$2"; shift 2 ;;
            -p )
                BOX_PROVIDER="$2"; shift 2 ;;
            -n )
                BOX_NAME="$2"; shift 2 ;;
            -f )
                BOX_FILE="$2"; shift 2 ;;
            -m )
                VM_NAME="$2"; shift 2 ;;
            -- )
                shift; break ;;
            * )
                break ;;
        esac
    done

    if [ ${CMD} == "create" ] || [ ${CMD} == "upload" ] || [ ${CMD} == "release" ]; then
        if [ -z "${TOKEN}" ]; then
            fatal "Vagrant cloud token required, Please set by environment variable: TOKEN."
        fi

        if [ -z "${BOX_VERSION}" ]; then
            error "Box version required!"
            usage ${CMD}
        fi
    fi

    if [ ${CMD} == "create" ] || [ ${CMD} == "upload" ]; then
        if [ -z "${BOX_PROVIDER}" ]; then
            error "Box provider required!"
            usage ${CMD}
        fi
    fi

    if [ -z "${BOX_NAME}" ]; then
        error "Box name required!"
        usage ${CMD}
    fi

    _${CMD}
}

_create() {
    info "Create version "${BOX_VERSION}
    response=$(curl -s -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        ${API_URL}/${BOX_NAME}/versions \
        --data '{ "version": { "version": "'${BOX_VERSION}'" } }')
    check_error ${response}
    echo ${response}

    info "Create provider "${BOX_PROVIDER}
    response=$(curl -s -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        ${API_URL}/${BOX_NAME}/version/${BOX_VERSION}/providers \
        --data '{ "provider": { "name": "'${BOX_PROVIDER}'" } }')
    check_error ${response}
    echo ${response}
    success "Create success"
}

_package() {
    info "Package box"

    BOX_FILE=$(simplify_name ${BOX_NAME}).box
    vagrant package --output build/${BOX_FILE}

    success "Package success"
}

_upload() {
    BOX_FILE=build/$(simplify_name ${BOX_NAME}).box

    if [ ! -f ${BOX_FILE} ]; then
        error "Box file ${BOX_FILE} not found!"
        usage upload
    fi

    case "$(uname -s)" in
        Darwin | Linux )
            null_device=/dev/null ;;
        CYGWIN* | MINGW* | MSYS* )
            null_device=NUL ;;
        *)
            fatal "OS not support: "$(uname -s)
        ;;
    esac

    info "Get upload token"
    response=$(curl -s -H "Authorization: Bearer ${TOKEN}" \
        ${API_URL}/${BOX_NAME}/version/${BOX_VERSION}/provider/${BOX_PROVIDER}/upload)
    check_error ${response}
    echo ${response}
    UPLOAD_PATH=$(json_val ${response}, "upload_path")

    info "Upload path: "${UPLOAD_PATH}
    info "Start upload"
    response=$(curl -X PUT -f -T ${BOX_FILE} ${UPLOAD_PATH} --progress-bar -o ${null_device} -w "%{http_code}")
    return_code=$?
    if [ ${return_code} != 0 ] || [ x${response} != "x200" ]; then
        fatal "Upload error"[${return_code},${response}]
    fi

    info "Upload success"
}

_release() {
    info "Release box"
    response=$(curl -s -H "Authorization: Bearer ${TOKEN}" \
        ${API_URL}/${BOX_NAME}/version/${BOX_VERSION}/release -X PUT)
    check_error ${response}
    echo ${response}
    success "Release success"
}

case "$1" in
    -h | --help | help ) usage $2 ;;
    create | package | upload | release ) run "$@" ;;
    * ) error "Invalid command -- $1"; usage ;;
esac
