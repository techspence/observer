# observer
A blue team tool for watching over domains using bug hunting methodology!

**Passive recon --> active recon --> fingerprinting/tracking/monitoring**

- The idea of this tool is to try to:
	a) find things that vulnerability scanners miss or don't check for
	b) find things that require more manual checking but can be scripted or automated to some extent
	c) track, monitor and alert on changes, deviations and other potentially interesting things

**Passive Recon**
- Potential new subdomains
- Potential new IPs
- Google dorking
- Pastebin
- Github searching
- theHarvester email scraping
- Interesting content
- Technology used

**Active Recon**
- Verify subdomains
- Certificate expiration check
- New certificates issued
- Open ports
- Services and versions
- Technology used
- Login form https only
- Nikto

**Changes to track/monitor/alert on**
- New/Removed/Modified subdomains
- Certificate expired/expiring soon
- New certificates issued
- New ports available
- New services or versions
- New findings on google, pastebin, etc.
