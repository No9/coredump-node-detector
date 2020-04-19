#!/bin/bash

# This file is licensed under the GPL v2 License.
# License text available at https://opensource.org/licenses/GPL-2.0

# Based on https://github.com/alexey-medvedchikov/core-dump-handler
# A Version of this software that was distributed under MIT License

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin"

umask 0177

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


DUMP_NAME="dump-${TS}-${HOSTNAME}-${EXE_NAME}-${REAL_PID}-${SIGNAL}"

head --bytes "${LIMIT_SIZE}" | tee ${DUMP_NAME}.core | (${COMPRESSOR} > "${DIRECTORY}/${DUMP_NAME}.core${EXT}")

CONT_NAME=$(cat ${DUMP_NAME}.core | strings | grep HOSTNAME | sed s/HOSTNAME=//g)
rm ${DUMP_NAME}.core   

crictl inspectp -o json `crictl pods | grep ${CONT_NAME} | awk '{ print($1)}'` > "${DIRECTORY}/${DUMP_NAME}.json"
IMAGE_ID=$(crictl ps -p ${CONT_NAME} | grep ${CONT_NAME} | awk '{ print($2) }')
crictl img | grep $IMAGE_ID | awk '{ printf( "{ \"repo\":\"%s\", \"tag\": \"%s\", \"id\": \"%s\", \"size\": \"%s\" }\n", $1, $2, $3, $4 )}' > "${DIRECTORY}/${DUMP_NAME}-image.json" 

chown 444 "${DIRECTORY}/${DUMP_NAME}.core${EXT}" "${DIRECTORY}/${DUMP_NAME}.json" "${DIRECTORY}/${DUMP_NAME}-image-info.json"
