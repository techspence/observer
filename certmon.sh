#!/bin/bash
# Adapted from https://gist.github.com/cgmartin/49cd0aefe836932cdc96

# Alert conditions
# If a certificate expires in:
# 60 days (2 months)
# 30 days (1 month)
# 14 days (2 weeks)
# 7 days (1 week)
# 1 day
# The day your certificate expires

domains="valid_domains.txt"
rootdn="spenceralessi.com"
expiredHeader="The certificate(s) on the following host(s) have expired:"
expiringSoonHeader="The certificate(s) on the following host(s) will be expiring soon:"
nonExpiringHeader="Certificates for the following domains are not expiring soon"
webHook="https://hooks.slack.com/services/<webhookURL>"

function getExpiration () {
	expiredays=$(echo $(( ($(date -d $1 +%s) - $(date -d $2 +%s)) / 86400 )) )
	echo "$expiredays"
}

function sendAlert () {
	hosts=$1
	emoji=":$2:"
	messageHeader="*$3*"
	curl -X POST -H 'Content-type: application/json' \
	  --data '{"text":"'"$emoji $messageHeader \n\n ${hosts[@]}"'","type":"mrkdwn"}' $webHook \
	  --silent --output /dev/null --show-error --fail
}

while read -r TARGET; do
	openssl s_client -connect "$TARGET":443 -servername "$rootdn" <<< "Q" >/dev/null 2>&1
	status=$?

	# Found a nice way to check for valid certs from here:
	# https://gist.github.com/cgmartin/49cd0aefe836932cdc96
	if [ $status -eq '0' ]; then
		echo "++ Valid cert found for $TARGET...checking the expiration date.."
		certExpirationDate=$(date -d "$(: | openssl s_client -connect "$TARGET":443 -servername "$TARGET" 2>/dev/null \
                                | openssl x509 -text \
                                | grep 'Not After' \
                                | awk '{print $4,$5,$7}')" '+%s')

		today=$(date +"%Y-%m-%d")
		certExpireDateTime=$(date -d @$certExpirationDate)
		certExpireDate=$(date --date="$certExpireDateTime" +"%Y-%m-%d")
		certExpiresIn=$(getExpiration "$certExpireDate" "$today")

		# If cert is expired
		if [[ "$certExpiresIn" -lt 0 ]]; then
			expiredHosts+=($TARGET)
			invertDate=$(echo $certExpiresIn | sed 's/-//g')
			expiredDate+=($certExpireDate)
			expiredFor+=($invertDate)
			echo "!!!!! --- CERTIFICATE EXPIRED --- !!!!!"
			echo "Domain: $TARGET"
			echo "Expired $invertDate days ago on $certExpireDate"
			echo ""
		# If cert expires today
		elif [[ "$certExpiresIn" == '0' ]]; then
			expiringHosts+=($TARGET)
			echo "** Certificate expires TODAY"
			echo "Domain: $TARGET"
			echo "Date cert will expire: $certExpireDate"
			echo ""
		# If cert expires tomorrow
		elif [[ "$certExpiresIn" == '1' ]]; then
			expiringHosts+=($TARGET)
			echo "** Certificate expires TOMORROW"
			echo "Domain: $TARGET"
			echo "Date cert will expire: $certExpireDate"
			echo ""
		# If cert expires in one week
		elif [[ "$certExpiresIn" == '7' ]]; then
			expiringHosts+=($TARGET)
			echo "** Certificate expiring in ONE WEEK"
			echo "Domain: $TARGET"
			echo "Date cert will expire: $certExpireDate"
			echo ""
		# If cert expires in two weeks
		elif [[ "$certExpiresIn" == '14' ]]; then
			expiringHosts+=($TARGET)
			echo "** Certificate expiring in TWO WEEKS"
			echo "Domain: $TARGET"
			echo "Date cert will expire: $certExpireDate"
			echo ""
		# If cert expires in one month
		elif [[ "$certExpiresIn" == '30' ]]; then
			expiringHosts+=($TARGET)
			echo "** Certificate expiring in ONE MONTH"
			echo "Domain: $TARGET"
			echo "Date cert will expire: $certExpireDate"
			echo ""
		# If cert expires in two months
		elif [[ "$certExpiresIn" == '60' ]]; then
			expiringHosts+=($TARGET)
			echo "** Certificate expiring in TWO MONTHS"
			echo "Domain: $TARGET"
			echo "Date cert will expire: $certExpireDate"
			echo ""
		# Certificate is valid for some other period of time greater than 60 days
		elif [[ "$certExpiresIn" -gt "60" ]]; then
			notExpiringHosts+=($TARGET)
	    	else
			: # do nothing
		fi
	  fi
done<"${domains}"


if [[ ${expiredHosts[@]} ]]; then
	hostData=$(for h in ${expiredHosts[@]}; do echo $h; done)
	sendAlert ${hostData[@]} "rotating_light" "$expiredHeader"
elif [[ ${expiringHosts[@]} ]]; then
	hostData=$(for h in ${expiringHosts[@]}; do echo $h; done)
	sendAlert "${hostData[@]}" warning "$expiringSoonHeader"
elif [[ ${notExpiringHosts[@]} ]]; then
	hostData=$(for h in ${notExpiringHosts[@]}; do echo $h; done)
	echo "Not expiring soon:"
	echo ${hostData[@]}
	sendAlert "${hostData[@]}" ok "$nonExpiringHeader"
else
	: # do nothing
fi


