#!/bin/bash

mkdir -p /root/OK-VPS/tools /root/OK-VPS/tools/file /root/wordlist /root/templates;
clear;

SUBDOMAINS_ENUMERATION () {
       #Golang
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Golang installation in progress ...";
	cd /root/OK-VPS/tools/file && wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz && tar -zxvf go1.20.5.linux-amd64.tar.gz -C /usr/local/ && mkdir ~/.go && GOROOT=/usr/local/go && GOPATH=~/.go && PATH=$PATH:$GOROOT/bin:$GOPATH/bin && update-alternatives --install "/usr/bin/go" "go" "/usr/local/go/bin/go" 0 && update-alternatives --set go /usr/local/go/bin/go;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Golang installation is done !"; echo "";
	#Subfinder
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Subfinder installation in progress ...";
	GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest > /dev/null 2>&1 && ln -s ~/go/bin/subfinder /usr/local/bin/ && go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@introduce_pagination_to_st;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Subfinder installation is done !"; echo "";
	#Assetfinder
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Assetfinder installation in progress ...";
	go install github.com/tomnomnom/assetfinder@latest > /dev/null 2>&1 && ln -s ~/go/bin/assetfinder /usr/local/bin/;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Assetfinder installation is done !"; echo "";
	#Findomain
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Findomain installation in progress ...";/usr/bin/
	cd /root/OK-VPS/tools/file && curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip > /dev/null 2>&1 && unzip /root/OK-VPS/tools/file/findomain-linux-i386.zip && chmod +x findomain > /dev/null 2>&1 && cp findomain /usr/bin/ && chmod  +x /usr/bin/findomain;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Findomain installation is done !"; echo "";
	#Github-subdomains
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Github-subdomains installation in progress ...";
	go install github.com/gwen001/github-subdomains@latest  > /dev/null 2>&1 && ln -s ~/go/bin/github-subdomains /usr/local/bin/;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Github-subdomains installation is done !"; echo "";
	#Amass
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Amass installation in progress ...";
	go install -v github.com/owasp-amass/amass/v4/...@master > /dev/null 2>&1 && ln -s ~/go/bin/amass /usr/local/bin/ && cd && cd .config && mkdir amass && cd amass && wget https://raw.githubusercontent.com/owasp-amass/amass/master/examples/config.yaml && wget https://raw.githubusercontent.com/owasp-amass/amass/master/examples/datasources.yaml;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Amass installation is done !"; echo "";
	#Lilly
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Lilly installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/Dheerajmadhukar/Lilly.git  > /dev/null 2>&1 && cd Lilly && chmod +x lilly.sh;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Lilly installation is done !"; echo "";
	#Crobat
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Crobat installation in progress ...";
	go install github.com/cgboal/sonarsearch/cmd/crobat@latest > /dev/null 2>&1 && ln -s ~/go/bin/crobat /usr/local/bin/;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Crobat installation is done !"; echo "";
	#Sudomy
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"Sudomy installation in progress ...";
	cd /root/OK-VPS/tools && git clone --recursive https://github.com/screetsec/Sudomy.git > /dev/null 2>&1 && cd Sudomy && python3 -m pip install -r requirements.txt && apt-get install npm && apt-get install jq && npm install -g phantomjs && apt-get install jq nmap phantomjs npm chromium parallel -y && npm i -g wappalyzer wscat && cp sudomy /usr/local/bin && cp sudomy.api /usr/local/bin && cp slack.conf /usr/local/bin && cp sudomy.conf /usr/local/bin > /dev/null 2>&1 && ln -s /root/OK-VPS/tools/Sudomy/sudomy /usr/local/bin/;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"Sudomy installation is done !"; echo "";
	#mapcidr
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"Mapcidr installation in progress ...";
	go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest > /dev/null 2>&1 && ln -s ~/go/bin/mapcidr /usr/local/bin/;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"Mapcidr installation is done !"; echo "";
	#AltDns
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}AltDns installation in progress ...";
	cd /root/OK-VPS/tools/file && git clone https://github.com/infosec-au/altdns.git && cd altdns && pip install --upgrade pip setuptools pyopenssl requests urllib3 cachecontrol && pip install -r requirements.txt;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}AltDns installation in progress ...";
	#CertCrunchy
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}CertCrunchy installation in progress ...";
	cd /root/OK-VPS/tools/file && git clone https://github.com/joda32/CertCrunchy.git > /dev/null 2>&1 && cd CertCrunchy && sudo pip3 install -r requirements.txt;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}CertCrunchy installation in progress ...";
	#chaos
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"chaos installation in progress ...";
	go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest > /dev/null 2>&1 && ln -s ~/go/bin/chaos /usr/local/bin/;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"chaos installation is done !"; echo "";
	#shodan
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"shodan installation in progress ...";
	apt install python3-shodan && shodan init Dw9DTE811cfQ6j59jGLfVAWAMDr0MCTT;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"shodan installation is done !"; echo "";
	#gotator
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"gotator installation in progress ...";
	go install github.com/Josue87/gotator@latest > /dev/null 2>&1 && ln -s ~/go/bin/gotator /usr/local/bin/;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"gotator installation is done !"; echo "";
        #ctfr
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"ctfr installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/UnaPibaGeek/ctfr.git && cd ctfr/ && pip3 install -r requirements.txt;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"ctfr installation is done !"; echo "";
        #cero
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"cero installation in progress ...";
	go install github.com/glebarez/cero@latest > /dev/null 2>&1 && ln -s ~/go/bin/cero /usr/local/bin/;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"cero installation is done !"; echo "";
	#AnalyticsRelationships
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"AnalyticsRelationships installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/Josue87/AnalyticsRelationships.git  > /dev/null 2>&1 && cd AnalyticsRelationships && go build -ldflags "-s -w && cp -r analyticsrelationships /usr/local/bin"; 
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"AnalyticsRelationships installation is done !"; echo "";
	#Galer
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"Galer installation in progress ...";
	GO111MODULE=on go install -v github.com/dwisiswant0/galer@latest > /dev/null 2>&1 && ln -s ~/go/bin/galer /usr/local/bin/;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"Galer installation is done !"; echo "";
        #knockpy
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"knockpy installation in progress ...";
        cd /root/OK-VPS/tools/file && wget https://github.com/guelfoweb/knock/archive/refs/tags/5.4.0.zip && unzip 5.4.0.zip && cd knock-5.4.0 && python3 setup.py install && knockpy --set apikey-virustotal=fbbb048214f36feb32fcf7e8aa262c26b2dfe5051d02de7d85da6b3acbbed778;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"knockpy installation is done !"; echo "";
        #censys
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"Censys installation in progress ...";
	cd /root/OK-VPS/tools && export CENSYS_API_ID=303b2554-31b0-4e2d-a036-c869f23bfb76 && export CENSYS_API_SECRET=sB8T2K8en7LW6GHOkKPOfEDVpdmaDj6t && git clone https://github.com/christophetd/censys-subdomain-finder.git > /dev/null 2>&1 && cd censys-subdomain-finder && apt install python3.8-venv -y && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt; 
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"Censys installation is done !"; echo ""
        #quickcert
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${RED}"quickcert installation in progress ...";
        GO111MODULE=on go install -v github.com/c3l3si4n/quickcert@HEAD > /dev/null 2>&1 && ln -s ~/go/bin/quickcert /usr/local/bin/;
	echo -e ${BLUE}"[SUBDOMAINS ENUMERATION]" ${GREEN}"quickcert installation is done !"; echo ""
}

DNS_RESOLVER () {
	#MassDNS
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"MassDNS installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/blechschmidt/massdns.git > /dev/null 2>&1 && cd massdns && make && make install > /dev/null 2>&1 && ln -s /root/OK-VPS/tools/massdns/bin/massdns /usr/local/bin/;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"MassDNS installation is done !"; echo "";
	#dnsx
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"dnsx installation in progress ...";
	GO111MODULE=on go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest > /dev/null 2>&1 && ln -s ~/go/bin/dnsx /usr/local/bin/;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"dnsx installation is done !"; echo "";
	#PureDNS
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"PureDNS installation in progress ...";
	GO111MODULE=on go install github.com/d3mondev/puredns/v2@latest > /dev/null 2>&1 && ln -s ~/go/bin/puredns /usr/local/bin;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"PureDNS installation is done !"; echo "";
	#shuffledns
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"SHuffleDNS installation in progress ...";
	go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest > /dev/null 2>&1 && ln -s ~/go/bin/shuffledns /usr/local/bin;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"SHuffelDNS installation is done !"; echo "";
	#dnsvalidator
	echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"DNSvalidator installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/vortexau/dnsvalidator.git && cd dnsvalidator && python3 setup.py install &&  pip3 install contextvars && pip3 install -e . && ln -s /root/OK-VPS/tools/dnsvalidator/dnsvalidator /usr/local/bin/;
	echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"DNSvalidator installation is done !"; echo "";
	#resolver
	#echo -e ${BLUE}"[DNS RESOLVER]" ${RED}"SHuffleDNS installation in progress ...";
        #dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 200 -o /root/wordlist/resolvers.txt;
	#echo -e ${BLUE}"[DNS RESOLVER]" ${GREEN}"SHuffelDNS installation is done !"; echo "";

 
}

VISUAL_tools () {
	#Aquatone
	echo -e ${BLUE}"[VISUAL /root/OK-VPS/tools]" ${RED}"Aquatone installation in progress ...";
	cd /root/OK-VPS/tools/file && wget install https://github.com/michenriksen/aquatone/releases/download/v$AQUATONEVER/aquatone_linux_amd64_$AQUATONEVER.zip > /dev/null 2>&1 && unzip aquatone_linux_amd64_$AQUATONEVER.zip > /dev/null 2>&1 && mv aquatone /usr/local/bin/;
	echo -e ${BLUE}"[VISUAL /root/OK-VPS/tools]" ${GREEN}"Aquatone installation is done !"; echo "";
	#Gowitness
	echo -e ${BLUE}"[VISUAL /root/OK-VPS/tools]" ${RED}"Gowitness installation in progress ...";
	go install github.com/sensepost/gowitness@latest > /dev/null 2>&1 && ln -s ~/go/bin/gowitness chmod +x /usr/local/bin/;
	echo -e ${BLUE}"[VISUAL /root/OK-VPS/tools]" ${GREEN}"Gowitness installation is done !"; echo "";
}

HTTP_PROBE () {
	#httpx
	echo -e ${BLUE}"[HTTP PROBE]" ${RED}"httpx installation in progress ...";
	GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest > /dev/null 2>&1 && ln -s ~/go/bin/httpx /usr/local/bin/;
	echo -e ${BLUE}"[HTTP PROBE]" ${GREEN}"Httpx installation is done !"; echo "";
	#httprobe
	echo -e ${BLUE}"[HTTP PROBE]" ${RED}"httprobe installation in progress ...";
	go install github.com/tomnomnom/httprobe@latest > /dev/null 2>&1 && ln -s ~/go/bin/httprobe /usr/local/bin/;
	echo -e ${BLUE}"[HTTP PROBE]" ${GREEN}"httprobe installation is done !"; echo "";
}

WEB_CRAWLING () {
	#Gospider
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"Gospider installation in progress ...";
	go install github.com/jaeles-project/gospider@latest > /dev/null 2>&1 && ln -s ~/go/bin/gospider /usr/local/bin/;
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"Gospider installation is done !"; echo "";
	#Hakrawler
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"Hakrawler installation in progress ...";
	go install github.com/hakluke/hakrawler@latest > /dev/null 2>&1 && ln -s ~/go/bin/hakrawler /usr/local/bin/;
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"Hakrawler installation is done !"; echo "";
	#ParamSpider
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"ParamSpider installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/devanshbatham/paramspider > /dev/null 2>&1 && cd ParamSpider && apt install python-pip -y && pip install .; 
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"ParamSpider installation is done !"; echo "";
	#Waybackurls
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"Waybackurls installation in progress ...";
	go install github.com/tomnomnom/waybackurls@latest > /dev/null 2>&1 && ln -s ~/go/bin/waybackurls /usr/local/bin/;
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"Waybackurls installation is done !"; echo "";
	#Guaplus
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"Gauplus installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/bp0lr/gauplus.git && cd gauplus && go build && mv gauplus /usr/local/bin/;
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"Gauplus installation is done !"; echo "";
	#katana
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"freq installation in progress ...";
	go install github.com/projectdiscovery/katana/cmd/katana@latest > /dev/null 2>&1 && ln -s ~/go/bin/katana /usr/local/bin/; 
        echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"freq installation in progress ...";
        #Waymore
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${RED}"Waymore installation in progress ...";
	git clone https://github.com/xnl-h4ck3r/waymore.git /opt/waymore || git -C /opt/waymore pull && pip3 install -r /opt/waymore/requirements.txt && ln -s /opt/waymore//waymore.py /usr/local/bin/waymore && chmod +x /usr/local/bin/waymore > /dev/null 2>&1;
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${GREEN}"Waymore installation is done !" ${RESTORE}; echo "";
        #Parameters
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"Parameters installation in progress ...";
	go install github.com/mrco24/parameters@latest > /dev/null 2>&1 && ln -s ~/go/bin/parameters /usr/local/bin/;
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"Parameters installation is done !"; echo "";
        #xnLinkFinder
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${RED}"xnLinkFinder installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/xnl-h4ck3r/xnLinkFinder.git && cd xnLinkFinder && python setup.py install > /dev/null 2>&1;
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${GREEN}"xnLinkFinder installation is done !" ${RESTORE}; echo "";
	#GF
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"GF installation in progress ...";
	go install github.com/tomnomnom/gf@latest > /dev/null 2>&1 && ln -s ~/go/bin/gf /usr/local/bin/;
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"GF installation in progress ...";
	#GF_P
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"GF_P installation in progress ...";
        cd &&  mkdir -p .gf && cd /root/OK-VPS/tools/file && git clone https://github.com/tomnomnom/gf && cd /root/OK-VPS/tools/file/gf/examples && cp *.json $HOME/.gf && cd /root/OK-VPS/tools/file && git clone https://github.com/1ndianl33t/Gf-Patterns && cd /root/OK-VPS/tools/file/Gf-Patterns && wget https://raw.githubusercontent.com/mrco24/Patterns/main/my-lfi.json && cp *.json $HOME/.gf;	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"GF_P installation in progress ...";
	#uro
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"GF_P installation in progress ...";
	cd /root/OK-VPS/tools/file && wget https://github.com/s0md3v/uro/archive/refs/tags/1.0.0-beta.zip && unzip 1.0.0-beta.zip && cd uro-1.0.0-beta && python3 setup.py install && cp -r  uro /usr/bin; 
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"GF_P installation in progress ...";
	#freq
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"freq installation in progress ...";
	cd /root/Tools && git clone https://github.com/takshal/freq.git && cd freq && mv main.go freq.go && go build freq.go && cp freq /usr/bin; 
        echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"freq installation in progress ...";
	#cmake
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"cmake installation in progress ...";
	wget -qO- "https://cmake.org/files/v3.22/cmake-3.22.1-linux-x86_64.tar.gz" | sudo tar --strip-components=1 -xz -C /usr/local; 
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"cmake installation in progress ...";
	#web-archive
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"web-archive installation in progress ...";
	go get -u github.com/cheggaaa/pb/v3 && go install github.com/mrco24/web-archive@latest > /dev/null 2>&1 && ln -s ~/go/bin/web-archive /usr/local/bin/; 
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"web-archive installation in progress ...";
        #otx-url
	echo -e ${BLUE}"[WEB CRAWLING]" ${RED}"web-archive installation in progress ...";
	go install github.com/mrco24/otx-url@latest > /dev/null 2>&1 && ln -s ~/go/bin/otx-url /usr/local/bin/; 
	echo -e ${BLUE}"[WEB CRAWLING]" ${GREEN}"web-archive installation in progress ...";
}

NETWORK_SCANNER () {
	#Nmap
	echo -e ${BLUE}"[NETWORK SCANNER]" ${RED}"Nmap installation in progress ...";
	apt-get install nmap -y && apt install -y libpcap-dev > /dev/null 2>&1;
	echo -e ${BLUE}"[NETWORK SCANNER]" ${GREEN}"Nmap installation is done !"; echo "";
	#masscan
	echo -e ${BLUE}"[NETWORK SCANNER]" ${RED}"Masscan installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/robertdavidgraham/masscan > /dev/null 2>&1 && cd masscan && make > /dev/null 2>&1 && make install > /dev/null 2>&1 && mv bin/masscan /usr/local/bin/;
	echo -e ${BLUE}"[NETWORK SCANNER]" ${GREEN}"Masscan installation is done !"; echo "";
	#naabu
	echo -e ${BLUE}"[NETWORK SCANNER]" ${RED}"Naabu installation in progress ...";
	GO111MODULE=on go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest > /dev/null 2>&1 && ln -s ~/go/bin/naabu /usr/local/bin/;
	echo -e ${BLUE}"[NETWORK SCANNER]" ${GREEN}"Naabu installation is done !"; echo "";
        #unimap
	echo -e ${BLUE}"[NETWORK SCANNER]" ${RED}"unimap installation in progress ...";
	cd /root/OK-VPS/tools && wget -N -c https://github.com/Edu4rdSHL/unimap/releases/download/0.5.1/unimap-linux && mv unimap-linux /usr/local/bin/unimap && chmod 755 /usr/local/bin/unimap && strip -s /usr/local/bin/unimap;
	echo -e ${BLUE}"[NETWORK SCANNER]" ${GREEN}"unimap installation is done !"; echo "";
}

HTTP_PARAMETER () {
	#Arjun
	echo -e ${BLUE}"[HTTP PARAMETER DISCOVERY]" ${RED}"Arjun installation in progress ...";
        pip3 install arjun;
        cd /root/OK-VPS/tools && https://github.com/s0md3v/Arjun.git && cd Arjun && pip3 install arjun && python3 setup.py install;
	echo -e ${BLUE}"[HTTP PARAMETER DISCOVERY]" ${GREEN}"Arjun installation is done !"; echo "";
	#x8
	echo -e ${BLUE}"[HTTP PARAMETER DISCOVERY]" ${RED}"x8 installation in progress ...";
	cd /root/OK-VPS/tools && 
	install https://github.com/Sh1Yo/x8/releases/download/v"$X8VER"/x8_linux.tar.gz > /dev/null 2>&1 && tar -zxvf x8_linux.tar.gz > /dev/null 2>&1 && mv x8 /usr/local/bin/x8;
	echo -e ${BLUE}"[HTTP PARAMETER DISCOVERY]" ${GREEN}"x8 installation is done !"; echo "";
}

FUZZING_TOOLS () {
	#ffuf
	echo -e ${BLUE}"[FUZZING TOOLS]" ${RED}"ffuf installation in progress ...";
	go install github.com/ffuf/ffuf@latest > /dev/null 2>&1 && ln -s ~/go/bin/ffuf /usr/local/bin/;
	echo -e ${BLUE}"[FUZZING TOOLS]" ${GREEN}"ffuf installation is done !"; echo "";
	#gobuster
	echo -e ${BLUE}"[FUZZING TOOLS]" ${RED}"Gobuster installation in progress ...";
	go install github.com/OJ/gobuster/v3@latest > /dev/null 2>&1 && ln -s ~/go/bin/gobuster /usr/local/bin/;
	echo -e ${BLUE}"[FUZZING TOOLS]" ${GREEN}"Gobuster installation is done !"; echo "";
	#wfuzz
	echo -e ${BLUE}"[FUZZING TOOLS]" ${RED}"wfuzz installation in progress ...";
	apt-install install wfuzz -y > /dev/null 2>&1;
	echo -e ${BLUE}"[FUZZING TOOLS]" ${GREEN}"wfuzz installation is done !"; echo "";
	#dirsearch
	echo -e ${BLUE}"[FUZZING TOOLS]" ${RED}"dirsearch installation in progress ...";
	sudo pip3 install git+https://github.com/maurosoria/dirsearch &>/dev/null
	echo -e ${BLUE}"[FUZZING TOOLS]" ${GREEN}"dirsearch installation is done !"; echo "";
	#feroxbuster
	echo -e ${BLUE}"[FUZZING TOOLS]" ${RED}"feroxbuster installation in progress ...";
	snap install feroxbuster &>/dev/null
	echo -e ${BLUE}"[FUZZING TOOLS]" ${GREEN}"feroxbuster installation is done !"; echo "";
	#feroxbuster2
	echo -e ${BLUE}"[FUZZING TOOLS]" ${RED}"dirsearch installation in progress ...";
	curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/master/install-nix.sh | bash &>/dev/null
	echo -e ${BLUE}"[FUZZING TOOLS]" ${GREEN}"dirsearch installation is done !"; echo "";
}

LFI_TOOLS () {
	#LFISuite
	echo -e ${BLUE}"[LFI TOOLS]" ${RED}"LFISuite installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/D35m0nd142/LFISuite.git > /dev/null 2>&1;
	echo -e ${BLUE}"[LFI TOOLS]" ${GREEN}"LFISuite installation is done !"; echo "";
        #LFISuite
	echo -e ${BLUE}"[LFI TOOLS]" ${RED}"LFISuite installation in progress ...";
	go install github.com/mrco24/mrco24-lfi@latest > /dev/null 2>&1 && ln -s ~/go/bin/mrco24-lfi /usr/local/bin/;
	echo -e ${BLUE}"[LFI TOOLS]" ${GREEN}"LFISuite installation is done !"; echo "";
}

Open_Redirect () {

        #openredirect
	echo -e ${BLUE}"[Open Redirect]" ${RED}"Open Redirect installation in progress ...";
	go install github.com/mrco24/open-redirect@latest > /dev/null 2>&1 && ln -s ~/go/bin/open-redirect /usr/local/bin/;
	echo -e ${BLUE}"[Open Redirect]" ${GREEN}"Open Redirect installation is done !"; echo "";
}

SSRF_TOOLS () {
	#SSRFmap
	echo -e ${BLUE}"[SSRF TOOLS]" ${RED}"SSRFmap installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/swisskyrepo/SSRFmap > /dev/null 2>&1 && cd SSRFmap && pip3 install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[SSRF TOOLS]" ${GREEN}"SSRFmap installation is done !"; echo "";
	#Gopherus
	echo -e ${BLUE}"[SSRF TOOLS]" ${RED}"Gopherus installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/tarunkant/Gopherus.git > /dev/null 2>&1 && cd Gopherus && chmod +x install.sh && ./install.sh > /dev/null 2>&1;
	echo -e ${BLUE}"[SSRF TOOLS]" ${GREEN}"Gopherus installation is done !"; echo "";
	#Interactsh
	echo -e ${BLUE}"[SSRF TOOLS]" ${RED}"Interactsh installation in progress ...";
	GO111MODULE=on go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client > /dev/null 2>&1 && ln -s ~/go/bin/interactsh-client /usr/local/bin/;
	echo -e ${BLUE}"[SSRF TOOLS]" ${GREEN}"Interactsh installation is done !"; echo "";
}

Http-Request-Smuggling () {
	#Request-Smuggling
	echo -e ${BLUE}"[SSTI TOOLS]" ${RED}"Http-Request-Smuggling installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/anshumanpattnaik/http-request-smuggling.git > /dev/null 2>&1 && cd http-request-smuggling && pip3 install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[SSTI TOOLS]" ${GREEN}"Http-Request-Smuggling installation is done !"; echo "";
}

SSTI_TOOLS () {
	#tplmap
	echo -e ${BLUE}"[SSTI TOOLS]" ${RED}"tplmap installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/epinna/tplmap.git > /dev/null 2>&1 && cd tplmap && pip install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[SSTI TOOLS]" ${GREEN}"tplmap installation is done !"; echo "";
}

API_TOOLS () {
	#Kiterunner
	echo -e ${BLUE}"[API TOOLS]" ${RED}"Kiterunner installation in progress ...";
	cd /root/OK-VPS/tools/file && wget install https://github.com/assetnote/kiterunner/releases/download/v"$KITERUNNERVER"/kiterunner_"$KITERUNNERVER"_linux_amd64.tar.gz > /dev/null 2>&1 && tar xvf kiterunner_"$KITERUNNERVER"_linux_amd64.tar.gz > /dev/null 2>&1 && mv kr /usr/local/bin;
	cd /root/OK-VPS/tools && mkdir -p kiterunner-wordlists && cd kiterunner-wordlists && wget install https://wordlists-cdn.assetnote.io/data/kiterunner/routes-large.kite.tar.gz > /dev/null 2>&1 && wget install https://wordlists-cdn.assetnote.io/data/kiterunner/routes-small.kite.tar.gz > /dev/null 2>&1 && for f in *.tar.gz; do tar xf "$f"; rm -Rf "$f"; done
	echo -e ${BLUE}"[API TOOLS]" ${GREEN}"Kiterunner installation is done !"; echo "";
}


WORDLISTS () {
	#SecLists
	echo -e ${BLUE}"[WORDLISTS]" ${RED}"SecLists installation in progress ...";
	cd /root/wordlist && git clone https://github.com/danielmiessler/SecLists.git > /dev/null 2>&1;
	cd /root/wordlist && git clone https://github.com/orwagodfather/WordList.git  > /dev/null 2>&1;
	cd /root/wordlist && git clone https://github.com/mrco24/mrco24-wordlist.git > /dev/null 2>&1;
	echo -e ${BLUE}"[WORDLISTS]" ${GREEN}"SecLists installation is done !"; echo "";
}

VULNS_XSS () {
	#Dalfox
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${RED}"Dalfox installation in progress ...";
	GO111MODULE=on go install -v github.com/hahwul/dalfox/v2@latest > /dev/null 2>&1 && ln -s ~/go/bin/dalfox /usr/local/bin/;
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${GREEN}"Dalfox installation is done !"; echo "";
	#XSStrike
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${RED}"XSStrike installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/s0md3v/XSStrike > /dev/null 2>&1 && cd XSStrike && pip3 install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${GREEN}"XSStrike installation is done !"; echo "";
 	#XSS_VIBES
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${RED}"XSS_VIBES installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/faiyazahmad07/xss_vibes.git > /dev/null 2>&1 && cd xss_vibes && pip3 install -r requirements > /dev/null 2>&1;
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${GREEN}"XSS_VIBES installation is done !"; echo "";
	#kxss
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${RED}"kxss installation in progress ...";
	cd /root/OK-VPS/tools && wget https://github.com/tomnomnom/hacks/archive/refs/heads/master.zip && unzip master.zip && cd hacks-master/kxss/ && go env -w GO111MODULE=auto && go build && cp kxss /usr/local/bin;
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${GREEN}"kxss installation is done !"; echo "";
	#Gxssgo
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${RED}"Gxss installation in progress ...";
	go install github.com/KathanP19/Gxss@latest > /dev/null 2>&1 && ln -s ~/go/bin/Gxss /usr/local/bin/; 
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${GREEN}"Gxss installation is done !"; echo "";
	#Findom-xss
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${RED}"findom-xss installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/dwisiswant0/findom-xss.git > /dev/null 2>&1 && cd findom-xss && chmod +x findom-xss.sh && rm -r LinkFinder && git clone https://github.com/GerbenJavado/LinkFinder.git > /dev/null 2>&1;
	echo -e ${BLUE}"[VULNERABILITY - XSS]" ${GREEN}"findom-xss installation is done !"; echo "";
}

VULNS_SQLI () {
	#SQLmap
	echo -e ${BLUE}"[VULNERABILITY - SQL Injection]" ${RED}"SQLMap installation in progress ...";
	apt-install install -y sqlmap > /dev/null 2>&1
	echo -e ${BLUE}"[VULNERABILITY - SQL Injection]" ${GREEN}"SQLMap installation is done !"; echo "";
	#NoSQLMap
	echo -e ${BLUE}"[VULNERABILITY - SQL Injection]" ${RED}"NoSQLMap installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/codingo/NoSQLMap.git > /dev/null 2>&1 && cd NoSQLMap && python setup.py install > /dev/null 2>&1;
	echo -e ${BLUE}"[VULNERABILITY - SQL Injection]" ${GREEN}"NoSQLMap installation is done !"; echo "";
	#ghauri
	echo -e ${BLUE}"[VULNERABILITY - SQL Injection]" ${RED}"NoSQLMap installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/r0oth3x49/ghauri.git > /dev/null 2>&1 && cd ghauri && python3 -m pip install --upgrade -r requirements.txt && python3 -m pip install -e . > /dev/null 2>&1;
	echo -e ${BLUE}"[VULNERABILITY - SQL Injection]" ${GREEN}"NoSQLMap installation is done !"; echo "";
        #Jeeves
	echo -e ${BLUE}"[VULNERABILITY - SQL]" ${RED}"Jeeves installation in progress ...";
	go install github.com/ferreiraklet/Jeeves@latest > /dev/null 2>&1 && ln -s ~/go/bin/Jeeves /usr/local/bin/; 
	echo -e ${BLUE}"[VULNERABILITY - SQL]" ${GREEN}"Jeeves installation is done !"; echo "";
	#time-sql
	echo -e ${BLUE}"[VULNERABILITY - SQL]" ${RED}"time-sql installation in progress ...";
	go install github.com/mrco24/time-sql@latest > /dev/null 2>&1 && ln -s ~/go/bin/time-sql /usr/local/bin/; 
	echo -e ${BLUE}"[VULNERABILITY - SQL]" ${GREEN}"time-sql installation is done !"; echo "";
        #mrco24-error-sql
	echo -e ${BLUE}"[VULNERABILITY - SQL]" ${RED}"error-sql installation in progress ...";
	go install github.com/mrco24/mrco24-error-sql@latest > /dev/null 2>&1 && ln -s ~/go/bin/mrco24-error-sql /usr/local/bin/; 
	echo -e ${BLUE}"[VULNERABILITY - SQL]" ${GREEN}"error-sql installation is done !"; echo "";
}

CMS_SCANNER () {
	#WPScan
	echo -e ${BLUE}"[CMS SCANNER]" ${RED}"WPScan  installation in progress ...";
	gem install wpscan > /dev/null 2>&1;
	echo -e ${BLUE}"[CMS SCANNER]" ${GREEN}"WPScan installation is done !"; echo "";
	#Droopescan
	echo -e ${BLUE}"[CMS SCANNER]" ${RED}"Droopescan installation in progress ...";
	pip3 install droopescan > /dev/null 2>&1;
	echo -e ${BLUE}"[CMS SCANNER]" ${GREEN}"Droopescan installation is done !"; echo "";
        #Nrich
	echo -e ${BLUE}"[CMS SCANNER]" ${RED}"Droopescan installation in progress ...";
	wget https://gitlab.com/api/v4/projects/33695681/packages/generic/nrich/latest/nrich_latest_amd64.deb && dpkg -i nrich_latest_amd64.deb > /dev/null 2>&1;
	echo -e ${BLUE}"[CMS SCANNER]" ${GREEN}"Droopescan installation is done !"; echo "";
	#AEM-Hacking
	echo -e ${BLUE}"[CMS SCANNER]" ${RED}"AEM-Hacking installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/0ang3el/aem-hacker.git > /dev/null 2>&1 && cd aem-hacker && pip3 install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[CMS SCANNER]" ${GREEN}"AEM-Hacking installation is done !"; echo "";
 	#WhatWaf
	echo -e ${BLUE}"[CMS SCANNER]" ${RED}"WPScan  installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/Ekultek/WhatWaf.git > /dev/null 2>&1 && cd WhatWaf && cp -r /root/tools/WhatWeb/WhatWaf/whatwaf /usr/local/bin;
	echo -e ${BLUE}"[CMS SCANNER]" ${GREEN}"WPScan installation is done !"; echo "";
}

VULNS_SCANNER () {
	#Nuclei + nuclei templates
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${RED}"Nuclei installation in progress ...";
	cd /root/OK-VPS/tools && wget https://github.com/projectdiscovery/nuclei/releases/download/v2.9.7/nuclei_2.9.7_linux_amd64.zip && unzip nuclei_2.9.7_linux_amd64.zip && mv nuclei /usr/local/bin/;
	cd /root/templates && git clone https://github.com/projectdiscovery/nuclei-templates.git > /dev/null 2>&1;
	cd /root/templates && git clone https://github.com/projectdiscovery/fuzzing-templates.git > /dev/null 2>&1;
        go install -v github.com/xm1k3/cent@latest > /dev/null 2>&1 && ln -s ~/go/bin/cent /usr/local/bin/ && cent init;
	echo -e ${BLUE}"[VULNERA BILITY SCANNER]" ${GREEN}"Nuclei installation is done !"; echo "";
	#Jaeles
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${RED}"Jaeles installation in progress ...";
	cd /root/OK-VPS/tools/file && wget https://github.com/jaeles-project/jaeles/releases/download/beta-v0.17/jaeles-v0.17-linux.zip > /dev/null 2>&1 && unzip jaeles-v0.17-linux.zip > /dev/null 2>&1 && mv jaeles /usr/local/bin/;
	cd /root/templates && git clone https://github.com/jaeles-project/jaeles-signatures.git > /dev/null 2>&1;
	cd /root/templates && git clone https://github.com/ghsec/ghsec-jaeles-signatures > /dev/null 2>&1;
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${GREEN}"Jaeles installation is done !"; echo "";
	#Nikto
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${RED}"Nikto installation in progress ...";
	apt-install install -y nikto > /dev/null 2>&1;
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${GREEN}"Nikto installation is done !"; echo "";
        #Xray
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${RED}"Xray installation in progress ...";
	cd /root/OK-VPS/tools && mkdir xray && cd xray && wget https://github.com/chaitin/xray/releases/download/1.9.11/xray_linux_amd64.zip && unzip xray_linux_amd64.zip && mv xray_linux_amd64 xray && wget https://github.com/mrco24/xray-config/raw/main/n.zip && unzip n.zip && cd n && cp -r *.yaml /root/OK-VPS/tools/xray;
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${GREEN}"Xray installation is done !"; echo "";
        #Afrog
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${RED}"Afrog installation in progress ...";
	go install -v github.com/zan8in/afrog/v2/cmd/afrog@latest > /dev/null 2>&1 && ln -s ~/go/bin/afrog /usr/local/bin/;
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${GREEN}"Afrog installation is done !"; echo "";
        #POC-bomber
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${RED}"POC-bomber installation in progress ..."; 
        cd /root/OK-VPS/tools && git clone https://github.com/tr0uble-mAker/POC-bomber.git && cd POC-bomber && pip install -r requirements.txt;
	echo -e ${BLUE}"[VULNERABILITY SCANNER]" ${GREEN}"POC-bomber installation is done !"; echo "";
}

JS_HUNTING () {
	#Linkfinder
	echo -e ${BLUE}"[JS FILES HUNTING]" ${RED}"Linkfinder installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/GerbenJavado/LinkFinder.git > /dev/null 2>&1 && cd LinkFinder && pip3 install -r requirements.txt > /dev/null 2>&1 && python3 setup.py install > /dev/null 2>&1;
	echo -e ${BLUE}"[JS FILES HUNTING]" ${GREEN}"Linkfinder installation is done !"; echo "";
	#SecretFinder
	echo -e ${BLUE}"[JS FILES HUNTING]" ${RED}"SecretFinder installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/m4ll0k/SecretFinder.git > /dev/null 2>&1 && cd SecretFinder && pip3 install -r requirements.txt && pip3 install jsbeautifier && pip3 install lxml > /dev/null 2>&1;
	echo -e ${BLUE}"[JS FILES HUNTING]" ${GREEN}"SecretFinder installation is done !"; echo "";
	#subjs
	echo -e ${BLUE}"[JS FILES HUNTING]" ${RED}"subjs installation in progress ...";
	go install -u github.com/lc/subjs@latest > /dev/null 2>&1 && ln -s ~/go/bin/subjs /usr/local/bin/;
	echo -e ${BLUE}"[JS FILES HUNTING]" ${GREEN}"subjs installation is done !"; echo "";
	#Getjs
	echo -e ${BLUE}"[JS FILES HUNTING]" ${RED}"Getjs installation in progress ...";
	go install github.com/003random/getJS@latest > /dev/null 2>&1 && ln -s ~/go/bin/getJS /usr/local/bin/;
	echo -e ${BLUE}"[JS FILES HUNTING]" ${GREEN}"Getjs installation in progress ...";
	#jsscanner
	echo -e ${BLUE}"[JS FILES HUNTING]" ${RED}"Jsscanner installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/dark-warlord14/JSScanner > /dev/null 2>&1 && cd JSScanner/ && bash install.sh > /dev/null 2>&1;
	echo -e ${BLUE}"[JS FILES HUNTING]" ${GREEN}"Jsscanner installation in progress ...";
}

GIT_HUNTING() {
	#GitDorker
	echo -e ${BLUE}"[GIT HUNTING]" ${RED}"gitGraber installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/obheda12/GitDorker.git > /dev/null 2>&1 && cd GitDorker && pip3 install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[GIT HUNTING]" ${GREEN}"gitGraber installation is done !"; echo "";
	#gitGraber
	echo -e ${BLUE}"[GIT HUNTING]" ${RED}"gitGraber installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/hisxo/gitGraber.git > /dev/null 2>&1 && cd gitGraber && pip3 install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[GIT HUNTING]" ${GREEN}"gitGraber installation is done !"; echo "";
	#GitHacker
	echo -e ${BLUE}"[GIT HUNTING]" ${RED}"GitHacker installation in progress ...";
	pip3 install GitHacker > /dev/null 2>&1;
	echo -e ${BLUE}"[GIT HUNTING]" ${GREEN}"GitHacker installation is done !"; echo "";
	#GitTools
	echo -e ${BLUE}"[GIT HUNTING]" ${RED}"GitToolsinstallation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/internetwache/GitTools.git > /dev/null 2>&1;
	echo -e ${BLUE}"[GIT HUNTING]" ${GREEN}"GitTools installation is done !"; echo "";
}


SENSITIVE_FINDING() {
	#DumpsterDiver
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${RED}"gitGraber installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/securing/DumpsterDiver.git > /dev/null 2>&1 && cd DumpsterDiver && pip3 install -r requirements.txt > /dev/null 2>&1;
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${GREEN}"gitGraber installation is done !"; echo "";
	#EarlyBird
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${RED}"EarlyBird installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/americanexpress/earlybird.git > /dev/null 2>&1 && cd earlybird && ./build.sh > /dev/null 2>&1 && ./install.sh > /dev/null 2>&1;
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${GREEN}"EarlyBird installation is done !"; echo "";
	#Ripgrep
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${RED}"Ripgrep installation in progress ...";
	apt-install install -y ripgrep > /dev/null 2>&1
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${GREEN}"Ripgrep installation is done !" ${RESTORE}; echo "";
	#Ripgrep
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${RED}"Gau-Expose installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/tamimhasan404/Gau-Expose.git > /dev/null 2>&1;
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${GREEN}"Gau-Expose installation is done !" ${RESTORE}; echo "";
        #Mantra
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${RED}"Mantra installation in progress ...";
	go install github.com/MrEmpy/mantra@latest && cp -r /root/go/bin/mantra /usr/local/bin > /dev/null 2>&1;
	echo -e ${BLUE}"[SENSITIVE FINDING TOOLS]" ${GREEN}"Mantra installation is done !" ${RESTORE}; echo "";
}

Find_Web_Technologies(){
#wappalyzer-cli
echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"wappalyzer-cli installation in progress ...";
cd /root/OK-VPS/tools && git clone https://github.com/gokulapap/wappalyzer-cli  > /dev/null 2>&1 && cd wappalyzer-cli && pip3 install . > /dev/null 2>&1;
echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"wappalyzer-cli installation in progress ...";
}

USEFUL_TOOLS () {
        #Oralyzer
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"Oralyzer installation in progress ...";
	cd /root/OK-VPS/tools &&  git clone https://github.com/r0075h3ll/Oralyzer.git && pip3 install -r requirements.txt;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"Oralyzer installation is done !"; echo "";
        #Notify
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"tok installation in progress ...";
	go install -v github.com/projectdiscovery/notify/cmd/notify@latest > /dev/null 2>&1 && ln -s ~/go/bin/notify /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"tok installation is done !"; echo "";
        #tok
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"tok installation in progress ...";
	GO111MODULE=on go get -u github.com/mrco24/tok > /dev/null 2>&1 && ln -s ~/go/bin/tok /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"tok installation is done !"; echo "";
	#installallurls
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"installallurls installation in progress ...";
	GO111MODULE=on go install -v github.com/lc/gau@latest > /dev/null 2>&1 && ln -s ~/go/bin/gau /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"installallurls installation is done !"; echo "";
	#anti-burl
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"anti-burl installation in progress ...";
	go install github.com/tomnomnom/hacks/anti-burl@latest > /dev/null 2>&1 && ln -s ~/go/bin/anti-burl /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"anti-burl installation is done !"; echo "";
	#unfurl
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"unfurl installation in progress ...";
	go install github.com/tomnomnom/unfurl@latest > /dev/null 2>&1 && ln -s ~/go/bin/unfurl /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"unfurl installation is done !"; echo "";
	#anew
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"anew installation in progress ...";
	go install github.com/tomnomnom/anew@latest > /dev/null 2>&1 && ln -s ~/go/bin/anew /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"anew installation is done !"; echo "";
	#subzy
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"subzy installation in progress ...";
	go install -v github.com/LukaSikic/subzy@latest > /dev/null 2>&1 && ln -s ~/go/bin/subzy /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"subzy installation in progress ...";
	#gron
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"gron installation in progress ...";
	go install github.com/tomnomnom/gron@latest > /dev/null 2>&1 && ln -s ~/go/bin/gron /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"gron installation is done !"; echo "";
	#qsreplace
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"qsreplace installation in progress ...";
	go install github.com/tomnomnom/qsreplace@latest > /dev/null 2>&1 && ln -s ~/go/bin/qsreplace /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"qsreplace installation is done !"; echo "";
	#Interlace
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"Interlace installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/codingo/Interlace.git > /dev/null 2>&1 && cd Interlace && python3 setup.py install > /dev/null 2>&1;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"Interlace installation is done !"; echo "";
	#Jq
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"jq installation in progress ...";
	apt-install install -y jq > /dev/null 2>&1;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"jq installation is done !" ${RESTORE}; echo "";
	#cf_check
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"jq installation in progress ...";
	go install github.com/dwisiswant0/cf-check@latest > /dev/null 2>&1 && ln -s ~/go/bin/cf-check /usr/local/bin/;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"jq installation is done !" ${RESTORE}; echo "";
	#Tmux
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"Tmux installation in progress ...";
	apt-install install tmux -y > /dev/null 2>&1;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"Tmux installation is done !"; echo "";
	#Uro
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"Uro installation in progress ...";
	pip3 install uro > /dev/null 2>&1;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"Uro installation is done !" ${RESTORE}; echo "";
        #SploitScan
	echo -e ${BLUE}"[USEFUL TOOLS]" ${RED}"SploitScan installation in progress ...";
	cd /root/OK-VPS/tools && git clone https://github.com/xaitax/SploitScan.git > /dev/null 2>&1;
	echo -e ${BLUE}"[USEFUL TOOLS]" ${GREEN}"SploitScan installation is done !"; echo "";
}

SUBDOMAINS_ENUMERATION && DNS_RESOLVER && VISUAL_tools && HTTP_PROBE && WEB_CRAWLING && NETWORK_SCANNER && HTTP_PARAMETER && FUZZING_TOOLS && LFI_TOOLS && SSRF_TOOLS && SSTI_TOOLS && API_TOOLS && WORDLISTS && VULNS_XSS && VULNS_SQLI && CMS_SCANNER && VULNS_SCANNER && JS_HUNTING && GIT_HUNTING  && SENSITIVE_FINDING && USEFUL_TOOLS;
