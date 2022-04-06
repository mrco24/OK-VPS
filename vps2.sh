#!/bin/sh

sudo apt-get install python3;
sudo apt-get install python3-pip;
sudo apt-get install ruby;
sudo apt-get install screen;
sudo apt-get install git;
mkdir /root/.gf
mkdir /root/Tools;
mkdir /root/Recon;
dir=/root/Tools;
go get -u github.com/m4ll0k/Aron;
go get github.com/Ice3man543/SubOver;
git clone https://github.com/tomnomnom/hacks $dir/hacks;
git clone https://github.com/tomnomnom/gf $dir/gf;
git clone https://github.com/zdresearch/OWASP-Nettacker $dir/OWASP-Nettacker;
go get -u github.com/tomnomnom/assetfinder;
go get -u github.com/tomnomnom/fff;
go get github.com/tomnomnom/hacks/filter-resolved;
go get -u github.com/tomnomnom/hacks/gittrees;
go get github.com/tomnomnom/hacks/waybackurls;
go get -u github.com/tomnomnom/hacks/unisub;
go get -u -v github.com/lukasikic/subzy;
go install -v github.com/lukasikic/subzy;
go get -u github.com/tomnomnom/unfurl;
go get github.com/tomnomnom/burl;
go get -u github.com/tomnomnom/meg;
go get -u github.com/j3ssie/metabigor;
go get -u github.com/rverton/webanalyze;
pip install requests;
go get -u github.com/c-bata/go-prompt;
go get github.com/hahwul/websocket-connection-smuggler;
GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei;
git clone https://github.com/projectdiscovery/nuclei-templates $dir/nuclei-templates;
go get github.com/haccer/subjack;
go get github.com/eth0izzle/shhgit;
GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/cmd/subfinder;
go get github.com/tiagorlampert/CHAOS;
GO111MODULE=on go get -u github.com/projectdiscovery/chaos-client/cmd/chaos;
GO111MODULE=on go get -u -v github.com/hahwul/dalfox;
go get github.com/ffuf/ffuf;
GO111MODULE=on go get -u -v github.com/lc/gau;
go get -u github.com/tomnomnom/gf;
cp -r /usr/local/go/src/github.com/tomnomnom/gf/examples ~/.gf/;
go get github.com/003random/getJS;
go get github.com/subfinder/goaltdns;
go get github.com/OJ/gobuster;
go get -u github.com/sensepost/gowitness;
go get -u github.com/jaeles-project/gospider;
go get github.com/hakluke/hakcheckurl;
go get github.com/hakluke/hakrawler;
go get github.com/hakluke/hakrevdns;
go get -u github.com/tomnomnom/httprobe;
GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx;
git clone https://github.com/udit-thakkur/AdvancedKeyHacks $dir/AdvancedKeyHacks;
git clone https://github.com/streaak/keyhacks $dir/keyhacks;
git clone https://github.com/s0md3v/Arjun $dir/Arjun;
git clone https://github.com/NullArray/AutoSploit $dir/AutoSploit;
git clone https://github.com/devanshbatham/FavFreak $dir/FavFreak;
git clone https://github.com/MichaelStott/CRLF-Injection-Scanner $dir/CRLF-Injection-Scanner;
git clone https://github.com/1N3/BruteX $dir/BruteX;
git clone https://github.com/AlexisAhmed/BugBountyTools $dir/BugBountyTools;
git clone https://github.com/gwen001/BBvuln $dir/BBvuln;
git clone https://github.com/D35m0nd142/LFISuite $dir/LFISuite;
git clone https://github.com/GerbenJavado/LinkFinder $dir/LinkFinder;
git clone https://github.com/pwn0sec/PwnXSS $dir/PwnXSS;
git clone https://github.com/hahwul/XSpear $dir/XSpear;
git clone https://github.com/jordanpotti/CloudScraper $dir/CloudScraper;
git clone https://github.com/swisskyrepo/SSRFmap $dir/SSRFmap;
git clone https://github.com/m4ll0k/SecretFinder $dir/SecretFinder;
git clone https://github.com/s0md3v/Striker $dir/Striker;
git clone https://github.com/devanshbatham/ParamSpider $dir/ParamSpider;
git clone https://github.com/j3ssie/Osmedeus $dir/Osmedeus;
git clone https://github.com/codingo/NoSQLMap $dir/NoSQLMap;
git clone https://github.com/nsonaniya2010/SubDomainizer $dir/SubDomainizer;
git clone https://github.com/s0md3v/XSStrike $dir/XSStrike;
GO111MODULE=on go get -u -v github.com/projectdiscovery/dnsprobe;
git clone https://github.com/maurosoria/dirsearch $dir/dirsearch;
git clone https://github.com/dwisiswant0/apkleaks $dir/apkleaks;
git clone https://github.com/ozguralp/gmapsapiscanner $dir/gmapsapiscanner;
git clone https://github.com/defparam/smuggler $dir/smuggler;
git clone https://github.com/epsylon/Smuggler $dir/epsylon_Smuggler;
git clone https://github.com/kowainik/smuggler $dir/kowa_smuggler;
GO111MODULE=on go get -u -v github.com/projectdiscovery/shuffledns/cmd/shuffledns;
git clone https://github.com/p4pentest/crtsh $dir/crtsh;
git clone https://github.com/XecLabs/Theif $dir/Theif;
git clone https://github.com/YashGoti/crtsh.py $dir/crtsh.py;
git clone https://github.com/epinna/tplmap $dir/tplmap;
git clone https://github.com/xmendez/wfuzz $dir/wfuzz;
git clone https://github.com/secdec/xssmap $dir/xssmap;
git clone https://github.com/hahwul/websocket-connection-smuggler $dir/websocket-connection-smuggler;
git clone https://github.com/rastating/wordpress-exploit-framework $dir/wordpress-exploit-framework;
git clone https://github.com/1ndianl33t/Gf-Patterns;
mv /root/Gf-Patterns/*.json /root/.gf/;
rm -rf /root/Gf-Patterns;
wget https://raw.githubusercontent.com/devanshbatham/ParamSpider/master/gf_profiles/potential.json;
mv /root/potential.json /root/.gf/;
echo 'source /usr/local/go/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc;
echo "
alias osmedeus='python3 /root/Tools/Osmedeus/osmedeus.py -m "subdomain,portscan,vuln,git,burp,ip" -t'
alias dirsearch='python3 /root/Tools/dirsearch/dirsearch.py -e php,asp,js,aspx,jsp,py,txt,conf,config,bak,backup,swp,old,db,sql -t 300 -u'
alias ffuf=/root/go/bin/ffuf
alias antiburl=/root/go/bin/anti-burl
alias kxss=/root/Tools/hacks/kxss/kxss
alias gittrees=/root/Tools/hacks/gittrees/gittrees
alias hakrawler=/root/go/bin/hakrawler
alias hakrevdns=/root/go/bin/hakrevdns
alias hakcheckurl=/root/go/bin/hakcheckurl
alias githound=/root/Tools/git-hound/git-hound
alias httpx=/root/go/bin/httpx
alias resolver=/root/arsenal/resolver.sh
alias subunique=/root/arsenal/unique_lister.sh
alias gau=/root/go/bin/gau
alias secretfinder='python3 /root/Tools/SecretFinder/SecretFinder.py'
alias qsreplace=/root/go/bin/qsreplace
alias nuclei=/root/go/bin/nuclei
alias nuclear=/root/arsenal/nuclear.sh
alias givesecrets=/root/arsenal/givesecrets.sh
alias getsec=/root/arsenal/getsec.sh
alias rex=/root/arsenal/rex.sh
alias gmapi='python3 /root/Tools/gmapsapiscanner/maps_api_scanner_python3.py'
alias Bheem=/root/arsenal/Bheem.sh
alias reverse=/root/arsenal/reverse.sh
alias corsy=/root/arsenal/corsy.sh
" >> /root/.bashrc;
echo "
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
" >> /root/.bashrc;
cd;
git clone https://github.com/harsh-bothra/Bheem.git;
mv /root/Bheem/arsenal /root/;
chmod +x /root/arsenal/*;
rm -rf /root/Bheem;
#. ~/.bashrc;
echo " Don't Forget to run ' source ~/.bashrc ' after completion"
echo "Configure subfinder /root/.config/subfinder/config.yaml"
echo "Update key /root/arsenal/extractor.sh"
