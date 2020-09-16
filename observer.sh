#!/bin/bash

# Enumerate subdomains
./domainenum.sh
wait $!

# Validate subdomains
./dnsvalidate.sh
wait $!

# Check certificates for all domains/subdomains
./certmon.sh
