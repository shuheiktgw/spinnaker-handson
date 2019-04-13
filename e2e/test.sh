#!/bin/sh

for i in `seq 0 4`
do
  echo "sending request to $URL"

  RESPONSE=$(curl $URL --retry 3 --connect-timeout 3)
  if [[ $? != 0 ]]; then
    echo "request failed"
    exit 1
  fi

  MESSAGE=$( echo ${RESPONSE} | jq .message)
  if [[ -z "${MESSAGE}" ]]; then
    echo "received invalid response, message cannot be blank"
    exit 1
  fi
done

exit 0