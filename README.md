# observer
A blue team tool for watching over domains using bug hunting methodology!

**Passive recon --> active recon --> fingerprinting/tracking/monitoring**

- The idea of this tool is to try to:
	a) find things that vulnerability scanners miss or don't check for
	b) find things that require more manual checking but can be scripted or automated to some extent
	c) track, monitor and alert on changes, deviations and other potentially interesting things

## Current & ToDo Features
**Passive Recon**
- [x] Potential new subdomains
- [ ] Potential new IPs
- [ ] Google dorking
- [ ] Pastebin
- [ ] Github searching
- [ ] theHarvester email scraping
- [ ] Interesting content
- [ ] Technology used

**Active Recon**
- [x] Verify subdomains
- [x] Certificate expiration check
- [ ] New certificates issued
- [ ] Open ports
- [ ] Services and versions
- [ ] Technology used
- [ ] Login form https only
- [ ] Nikto

**Changes to track/monitor/alert on**
- [x] New/Removed/Modified subdomains
- [x] Certificate expired/expiring soon
- [ ] New certificates issued
- [ ] New ports available
- [ ] New services or versions
- [ ] New findings on google, pastebin, etc.

## High Level Workflow
- Subdomain Enumeration > New Subdomain Alerting > Subdomain DNS Validation > Certificate Monitoring

Step 1. Passively enumerate domains with Amass
`/opt/Amass/amass enum --passive -d spenceralessi.com -o amass_domains.txt`

Step 2. Feed the output of Step 1. (`DomainMonitor`) to Step 2. to validate subdomains with massdns
`/opt/massdns/bin/massdns -r /opt/massdns/lists/resolvers.txt -t A -o S -w massdns_domains.txt amass_domains.txt > /dev/null 2>&1`

Step 2a. Export just subdomains
`cat massdns_domains.txt | awk '{print $1}' | sed 's/.$//' | sort -u > valid_domains.txt`

Step 3. Feed Step 2a. (`valid_domains`) to certmon


## Inspiration
- https://0xpatrik.com/subdomain-enumeration-2019/
- Jason Haddix Bughunter Methodology - https://www.youtube.com/watch?v=gIz_yn0Uvb8
- https://medium.com/@noobhax/my-recon-process-dns-enumeration-d0e288f81a8a
