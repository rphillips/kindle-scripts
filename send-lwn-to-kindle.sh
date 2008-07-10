#!/usr/bin/env bash

# Required Tools:
#   CURL, mime-construct, prince (for PDF generation)

TO="[kindlename]@free.kindle.com"
FROM="authorized_kindle_email@someplace.com"

LWN_USERNAME=your_lwn_username
LWN_PASSWORD=your_lwn_password

LWN_LOGIN_PAGE=http://lwn.net/login
LWN_CURRENT_ISSUE=http://lwn.net/current/bigpage
LWN_TMP_FILE=/tmp/lwnissue.html
LWN_PDF=/tmp/LWN-`date +%d-%m-%Y`.pdf

CURL_AGENT="send-lwn-to-kindle"
CURL_COOKIEJAR=/tmp/.lwncookies
CURL_OPTIONS_LOGIN="-A ${CURL_AGENT} -k -c ${CURL_COOKIEJAR} -L ${LWN_LOGIN_PAGE}?Username=${LWN_USERNAME}&Password=${LWN_PASSWORD}"
CURL_OPTIONS_FETCH_ISSUE="-A ${CURL_AGENT} -L -b ${CURL_COOKIEJAR} ${LWN_CURRENT_ISSUE} -o ${LWN_TMP_FILE}"

cleanup() {
    rm -f $CURL_COOKIEJAR
    rm -f $LWN_TMP_FILE
    rm -f $LWN_PDF
}

curl ${CURL_OPTIONS_LOGIN} &> /dev/null
if [ "$?" != 0 ] ; then
    echo "Login Failed"
    cleanup
    exit 1
fi

curl ${CURL_OPTIONS_FETCH_ISSUE} &> /dev/null
if [ "$?" != 0 ] ; then
    echo "Fetch Failed"
    cleanup
    exit 1
fi

/opt/prince/bin/prince ${LWN_TMP_FILE} -o ${LWN_PDF} &> /dev/null

mime-construct --header "From: ${FROM}" --subject "LWN Current" --file-attach ${LWN_PDF} --to ${TO}

cleanup
