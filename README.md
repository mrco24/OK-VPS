<h1 align="center">
<a href="https://cooltext.com"><img src="https://images.cooltext.com/5599195.png" width="279" height="85" alt="OK-VPS" />
</h1>
<h4 align="center">Bug Bounty Vps Setup Tools Installer</h4>
<p align="center">
  <a href="https://github.com/mrco24/OK-VPS">
    <img src="https://img.shields.io/badge/Project-ok--vps-green">
  </a>
   <a href="https://github.com/mrco24/OK-VPS">
    <img src="https://img.shields.io/static/v1?label=Update&message=V1.0&color=green">
  </a>
  <a href="https://twitter.com/mrco24">
      <img src="https://img.shields.io/twitter/follow/mrco24?style=social">
  </a>
</p>

# install-all-tools

With these tools you can install most of the bug bounty tools with just one command 

## Installation 

```
apt-get update -y && apt-get install git -y && git clone https://github.com/mrco24/OK-VPS.git && cd OK-VPS && chmod +x okvps.sh && ./okvps.sh
```

## Use
```
./okvps.sh

<img width="1280" height="855" alt="image" src="https://github.com/user-attachments/assets/1621c8ef-7cac-41bb-bd7d-b36f00e420a3" />

```
## Display a summary of all tools that failed during the last installation attempt
./okvps.sh -f  

<img width="1209" height="184" alt="image" src="https://github.com/user-attachments/assets/907b06e9-d527-4907-9fd5-7450eaab6e14" />

```
## Available tools list

### Subdomains enumeration

- [Amass](https://github.com/OWASP/Amass)
- [Assetfinder](https://github.com/tomnomnom/assetfinder)
- [Crobat](https://github.com/Cgboal/SonarSearch)
- [Findomain](https://github.com/Findomain/Findomain)
- [Github-subdomains](https://github.com/gwen001/github-subdomains)
- [Subfinder](https://github.com/projectdiscovery/subfinder)
- [Sudomy](https://github.com/screetsec/Sudomy)
- [CertCrunchy](https://github.com/joda32/CertCrunchy)
- [AnalyticsRelationships](https://github.com/Josue87/AnalyticsRelationships)
- [Lilly](https://github.com/Dheerajmadhukar/Lilly)
- [Gotator](https://github.com/Josue87/gotator)
- [galer](https://github.com/dwisiswant0/galer)


### DNS resolver

- [dnsx](https://github.com/projectdiscovery/dnsx)
- [MassDNS](https://github.com/blechschmidt/massdns)
- [PureDNS](https://github.com/d3mondev/puredns)
- [ShuffleDNS](https://github.com/projectdiscovery/shuffledns)
- [DNSvalidator](https://github.com/vortexau/dnsvalidator)
  
### Screenshot

- [Aquatone](https://github.com/michenriksen/aquatone)
- [Gowitness](https://github.com/sensepost/gowitness)

### HTTP probe

- [httprobe](https://github.com/tomnomnom/httprobe)
- [httpx](https://github.com/projectdiscovery/httpx)

### Web crawler

- [Gospider](https://github.com/jaeles-project/gospider)
- [Hakrawler](https://github.com/hakluke/hakrawler)
- [ParamSpider](https://github.com/devanshbatham/ParamSpider)
- [gau](https://github.com/lc/gau)
- [waybackurls](https://github.com/tomnomnom/waybackurls)
- [paramspider](https://github.com/devanshbatham/ParamSpider)
- [GF](https://github.com/tomnomnom/gf)
- [GF_Pattern](https://github.com/1ndianl33t/Gf-Patterns)

### Network scanner

- [Masscan](https://github.com/robertdavidgraham/masscan)
- [Naabu](https://github.com/projectdiscovery/naabu)
- [Nmap](https://nmap.org/)

### HTTP parameter

- [Arjun](https://github.com/s0md3v/Arjun)
- [x8](https://github.com/Sh1Yo/x8/) *

### Fuzzing tools

- [ffuf](https://github.com/ffuf/ffuf)
- [Gobuster](https://github.com/OJ/gobuster)
- [wfuzz](https://github.com/xmendez/wfuzz) *
- [feroxbuster](https://github.com/epi052/feroxbuster)

### LFI tools

- [LFISuite](https://github.com/D35m0nd142/LFISuite) *

### SSRF tools

- [SSRFmap](https://github.com/swisskyrepo/SSRFmap)
- [Gopherus](https://github.com/tarunkant/Gopherus)
- [Interactsh](https://github.com/projectdiscovery/interactsh)

### Http-Request-Smugglingh
- [Http-Request-Smugglingh](https://github.com/anshumanpattnaik/http-request-smugglingh)

### SSTI tools

- [tplmap](https://github.com/epinna/tplmap) *

### API hacking tools

- [Kiterunner + API routes](https://github.com/assetnote/kiterunner)

### Wordlists

- [SecLists](https://github.com/danielmiessler/SecLists)

### Vulns - XSS

- [Dalfox](https://github.com/hahwul/dalfox)
- [kxss](https://github.com/tomnomnom/hacks/tree/master/kxss)
- [XSStrike](https://github.com/s0md3v/XSStrike)
- [Gxss](https://github.com/KathanP19/Gxss)
- [FinDOM-XSS](https://github.com/dwisiswant0/findom-xss)

### Vulns - SQL Injection

- [NoSQLMap](https://github.com/codingo/NoSQLMap)
- [SQLMap](https://github.com/sqlmapproject/sqlmap)

### CMS Scanner

- [WPscan](https://github.com/wpscanteam/wpscan)
- [droopescan](https://github.com/droope/droopescan)
- [AEM-Hacker](https://github.com/0ang3el/aem-hacker)

### Vulns - Scanner

- [Jaeles](https://github.com/jaeles-project/jaeles)
- [Nikto](https://github.com/sullo/nikto) **
- [Nuclei](https://github.com/projectdiscovery/nuclei)

### JavaScript hunting

- [LinkFinder](https://github.com/GerbenJavado/LinkFinder)
- [SecretFinder](https://github.com/m4ll0k/SecretFinder)
- [subjs](https://github.com/lc/subjs)
- [GetJS](https://github.com/003random/getJS)
- 
## Find_Web_Technologies

- [Wappalyzer CLI](https://github.com/gokulapap/wappalyzer-cli)

### Git hunting

- [GitDorker](https://github.com/obheda12/GitDorker) *
- [gitGraber](https://github.com/hisxo/gitGraber) *
- [GitHacker](https://github.com/WangYihang/GitHacker) *
- [GitTools](https://github.com/internetwache/GitTools) *

### Sensitive stuff finding

- [DumpsterDiver](https://github.com/securing/DumpsterDiver) *
- [EarlyBird](https://github.com/americanexpress/earlybird) *
- [Ripgrep](https://github.com/BurntSushi/ripgrep)

### Useful tools

- [anew](https://github.com/tomnomnom/anew)
- [anti-burl](https://github.com/tomnomnom/hacks/tree/master/anti-burl)
- [getallurls](https://github.com/lc/hacks/tree/master/getallurls)
- [gron](https://github.com/tomnomnom/gron)
- [Interlace](https://github.com/codingo/Interlace)
- [jq](https://github.com/stedolan/jq) *
- [qsreplace](https://github.com/tomnomnom/qsreplace)
- [Tmux](https://github.com/tmux/tmux)
- [unfurl](https://github.com/tomnomnom/unfurl)
- [Uro](https://github.com/s0md3v/uro) *

### Note

- Refer to the usage of the tools as most of them require configuration (especially for subdomains enumeration).
- Please be careful with these tools and only use them on targets you have explicitly authorized.

**N.B** : * = added in the last update

** For Nikto and Debian 10, you need to have the non-free contrib sources in addition. e.g : 
```
deb http://deb.debian.org/debian/ buster main contrib non-free
deb-src http://deb.debian.org/debian/ buster main contrib non-free
```
