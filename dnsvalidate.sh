#!/bin/bash

# Validate subdomains found from domainenum.sh
/opt/massdns/bin/massdns -r /opt/massdns/lists/resolvers.txt -t A -o S -w massdns_domains.txt amass_domains.txt > /dev/null 2>&1

# Export only domains/subdomains & remove duplicates
cat massdns_domains.txt | awk '{print $1}' | sed 's/.$//' | sed 's|www.||g' | sort -u > valid_domains.txt

# Run certmon.sh
./certmon.sh
