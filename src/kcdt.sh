#!/bin/bash

# Copyright IBM Corp. 2020. All Rights Reserved.
# This file is licensed under the MIT License.
# License text available at https://opensource.org/licenses/MIT

# Based of the https://github.com/alexey-medvedchikov/core-dump-handler

PATH="/bin:/sbin:/usr/bin:/usr/sbin"

umask 0177

DIRECTORY="/root/core"

for i in "$@"
do
case $i in
    -c=*|--limit-size=*)
        LIMIT_SIZE="${i#*=}"; shift
    ;;
    -e=*|--exe-name=*)
        EXE_NAME="${i#*=}"; shift
    ;;
    -p=*|--pid=*)
        REAL_PID="${i#*=}"; shift
    ;;
    -s=*|--signal=*)
        SIGNAL="${i#*=}"; shift
    ;;
    -t=*|--timestamp=*)
        TS="${i#*=}"; shift
    ;;
    -d=*|--dir=*)
        DIRECTORY="${i#*=}"; shift
    ;;
    -h=*|--hostname=*)
        HOSTNAME="${i#*=}"; shift
    ;;
    -E=*|--pathname=*)
        PATHNAME="${i#*=}"; shift
    ;;
esac
done

if [[ "_0" = "_${LIMIT_SIZE}" ]]; then
    exit 0
fi

if lz4 --version >/dev/null 2>&1; then
    COMPRESSOR="lz4 -1"
    EXT=.lz4
elif lzop --version >/dev/null 2>&1; then
    COMPRESSOR="lzop -1"
    EXT=.lzo
elif gzip --version >/dev/null 2>&1; then
    COMPRESSOR="gzip -3"
    EXT=.gz
else
    COMPRESSOR=cat
    EXT=
fi

if [[ ! -d "${DIRECTORY}" ]]; then
    mkdir -p "${DIRECTORY}"
    chown root:root "${DIRECTORY}"
    chmod 0600 "${DIRECTORY}"
fi


DUMP_NAME="dump-${TS}-${HOSTNAME}-${EXE_NAME}-${REAL_PID}-${SIGNAL}"

head --bytes "${LIMIT_SIZE}" | tee ${DUMP_NAME}.core | (${COMPRESSOR} > "${DIRECTORY}/${DUMP_NAME}.core${EXT}")

CONT_NAME=$(cat ${DUMP_NAME}.core | strings | grep HOSTNAME | sed s/HOSTNAME=//g)
rm ${DUMP_NAME}.core   

crictl inspectp -o json `crictl pods | grep ${CONT_NAME} | awk '{ print($1)}'` > "${DIRECTORY}/${DUMP_NAME}.json"
