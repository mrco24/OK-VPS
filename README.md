# mrco24 vps
Automatically install some web hacking/bug bounty tools for your VPS.

# O.S supported ✔️

Debian 10/11 x64

Kali Linux 2021.4 x64

Linux Mint 20.2 x64

Ubuntu20.04 x64

# Installation
apt-get update -y && apt-get install git -y
cd /tmp && git clone https://github.com/supr4s/VPS-web-hacking-tools && cd VPS-web-hacking-tools && ./installer.sh
#Available tools list
# Subdomains enumeration
 Amass
 Assetfinder
 Crobat
 Findomain
 Github-subdomains
 Subfinder
# DNS resolver
dnsx
MassDNS
PureDNS
# Visual recon
Aquatone
Gowitness
HTTP probe
httprobe
httpx
# Web crawler
Gospider
Hakrawler
Network scanner
Masscan
Naabu
Nmap
HTTP parameter
Arjun
x8 *
# Fuzzing tools
ffuf
Gobuster
wfuzz *
# LFI tools
LFISuite *
SSRF tools
SSRFmap
Gopherus
Interactsh
SSTI tools
tplmap *
# API hacking tools
Kiterunner + API routes
Wordlists
SecLists
Vulns - XSS
Dalfox
kxss
XSStrike
# Vulns - SQL Injection
NoSQLMap
SQLMap
CMS Scanner
WPscan
droopescan
AEM-Hacker
# Vulns - Scanner
Jaeles
Nikto **
Nuclei
JavaScript hunting
LinkFinder
SecretFinder
subjs
#Git hunting
GitDorker *
gitGraber *
GitHacker *
GitTools *
# Sensitive stuff finding
DumpsterDiver *
EarlyBird *
Ripgrep
#Useful tools
anew
anti-burl
getallurls
gron
Interlace
jq *
qsreplace
Tmux
unfurl
Uro *
# Note
Refer to the usage of the tools as most of them require configuration (especially for subdomains enumeration).
Please be careful with these tools and only use them on targets you have explicitly authorized.
N.B : * = added in the last update

# For Nikto and Debian 10, you need to have the non-free contrib sources in addition. e.g :

deb http://deb.debian.org/debian/ buster main contrib non-free
deb-src http://deb.debian.org/debian/ buster main contrib non-free

