# Setup Jumpbox setup to connect back to Cloudflare (browser based SSH)

PACKAGES="wget \
          bind9-dnsutils \
          bind9-host \
          whois \
          vim \
          tcpdump \
          golang \
          git \
          python3-pip \
          python3"

# Add alias to check startup script
echo 'alias log="sudo journalctl -o cat -f _SYSTEMD_UNIT=google-startup-scripts.service"' >> /etc/profile.d/00-aliases.sh
echo 'alias cfstatus="sudo systemctl status cloudflared"' >> /etc/profile.d/00-aliases.sh
echo 'alias mylocation="curl ipinfo.io"' >> /etc/profile.d/00-aliases.sh

cd /tmp

# The OS is updated and utilities are installed
sudo apt update -y && sudo apt upgrade -y
sudo apt install $PACKAGES -y

cd

# The package for this OS is retrieved 
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# A local user directory is first created before we can install the tunnel as a system service 
mkdir ~/.cloudflared
touch ~/.cloudflared/cert.json
touch ~/.cloudflared/config.yml

# Another herefile is used to dynamically populate the JSON credentials file 
cat > ~/.cloudflared/cert.json << "EOF"
{
    "AccountTag"   : "${account}",
    "TunnelID"     : "${tunnel_id}",
    "TunnelName"   : "${tunnel_name}",
    "TunnelSecret" : "${secret}"
}
EOF
# Same concept with the Ingress Rules the tunnel will use 
cat > ~/.cloudflared/config.yml << "EOF"
tunnel: ${tunnel_id}
credentials-file: /etc/cloudflared/cert.json
logfile: /var/log/cloudflared.log
loglevel: info

ingress:
  - hostname: ${zone1}
    service: ssh://localhost:22
  - hostname: "*"
    path: "^/_healthcheck$"
    service: http_status:200
  - hostname: "*"
    service: hello-world
EOF

# Now we install the tunnel as a systemd service 
sudo cloudflared service install

# The credentials file does not get copied over so we'll do that manually 
sudo cp -via ~/.cloudflared/cert.json /etc/cloudflared/
sudo cp -via ~/.cloudflared/config.yml /etc/cloudflared/

# Start the tunnel 
cd /tmp
sudo cloudflared service install
sudo service cloudflared start

# Change SSH configuration to support browser based 

sudo cat > /etc/ssh/ca.pub << "EOF"
${ssh_ca_cert}
EOF

sudo sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
sudo sed -i '$ a TrustedUserCAKeys /etc/ssh/ca.pub' /etc/ssh/sshd_config
sudo systemctl restart ssh