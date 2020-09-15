#!/bin/bash

# Alternative way to enumerate
# Use all your known IPs and give amass your domain
# /opt/Amass/amass enum -silent -ip -src -addr <my.ip.range.here-my.ending.ip.range> -d <DOMAIN>

/opt/Amass/amass enum -silent -d spenceralessi.com -o amass_domains.txt

hosts=$(/opt/Amass/amass track -d spenceralessi.com -last 2)

no_differences="*No differences discovered*"
if [[ $hosts == $no_differences ]]; then
  : # No new hosts discovered..
else
  curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"'"$hosts"'"}' https://hooks.slack.com/services/<webhookURL> \
    --silent --output /dev/null --show-error --fail
fi

# Validate domains
./dnsvalidate.sh
