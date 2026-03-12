#!/bin/bash

read -p "Enter username: " u
read -sp "Enter password: " p && echo

# Create SSH user
useradd -m "$u" -s /bin/bash
echo "$u:$p" | chpasswd

# Install stunnel if not installed
apt update && apt install -y stunnel4

# Create stunnel config
cat > /etc/stunnel/stunnel.conf <<EOF
client = no
[ssh]
accept = 443
connect = 22
cert = /etc/stunnel/stunnel.pem
EOF

# Generate self-signed certificate
openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/CN=localhost"

# Enable and restart stunnel
systemctl enable stunnel4
systemctl restart stunnel4

echo "User $u created and Stunnel SSH set on port 443"
