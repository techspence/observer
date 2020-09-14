#!/bin/bash

/opt/Amass/amass enum -silent --passive -d spenceralessi.com -o amass_domains.txt

hosts=$(/opt/Amass/amass track -d spenceralessi.com -last 2)

no_differences="*No differences discovered*"
if [[ $hosts == $no_differences ]]; then
  : # No new hosts discovered..
else
  curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"'"$hosts"'"}' https://hooks.slack.com/services/<webhookurl> \
    --silent --output /dev/null --show-error --fail
fi
