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

if gzip --version >/dev/null 2>&1; then
    COMPRESSOR="gzip -3"
    EXT=.gz
else
    COMPRESSOR=cat
    EXT=
fi

UUID=$(uuidgen)

DUMP_NAME="${UUID}-dump-${TS}-${HOSTNAME}-${EXE_NAME}-${REAL_PID}-${SIGNAL}"

echo "{ \"uuid\":\"${UUID}\", \"dump_file\":\"${DUMP_NAME}.core${EXT}\", \"ext\": \"${EXT}\", \"timestamp\": \"${TS}\", \"hostname\": \"${HOSTNAME}\", \"exe\": \"${EXE_NAME}\", \"real_pid\": \"${REAL_PID}\", \"signal\": \"${SIGNAL}\" }" > "${DIRECTORY}/${DUMP_NAME}-dump-info.json" 

head --bytes "${LIMIT_SIZE}" | tee ${DUMP_NAME}.core | (${COMPRESSOR} > "${DIRECTORY}/${DUMP_NAME}.core${EXT}")

CONT_NAME=$(cat ${DUMP_NAME}.core | strings | grep HOSTNAME | sed s/HOSTNAME=//g)
rm ${DUMP_NAME}.core   

crictl inspectp -o json `crictl pods | grep ${CONT_NAME} | awk '{ print($1)}'` > "${DIRECTORY}/${DUMP_NAME}-runtime-info.json"

POD_ID=$(crictl pods | grep ${CONT_NAME} | awk '{ print($1)}')

IMAGE_ID=$(crictl ps -p ${POD_ID} | grep ${POD_ID} | awk '{ print($2) }')

crictl img | grep $IMAGE_ID | awk '{ printf( "{ \"repo\":\"%s\", \"tag\": \"%s\", \"id\": \"%s\", \"size\": \"%s\" }\n", $1, $2, $3, $4 )}' > "${DIRECTORY}/${DUMP_NAME}-image-info.json"

chmod 444 "${DIRECTORY}/${DUMP_NAME}.core${EXT}" "${DIRECTORY}/${DUMP_NAME}-runtime-info.json" "${DIRECTORY}/${DUMP_NAME}-image-info.json" "${DIRECTORY}/${DUMP_NAME}-dump-info.json"
