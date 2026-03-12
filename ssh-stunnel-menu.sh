#!/bin/bash

# Detect platform
if command -v pkg &>/dev/null; then
    PKG_INSTALL="pkg install -y"
elif command -v apt &>/dev/null; then
    PKG_INSTALL="apt update && apt install -y"
else
    echo "Unsupported system"
    exit 1
fi

# Install stunnel if not installed
if ! command -v stunnel &>/dev/null; then
    echo "Installing Stunnel..."
    $PKG_INSTALL stunnel4 openssl
fi

# Generate certificate if not exists
if [ ! -f /etc/stunnel/stunnel.pem ]; then
    openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/CN=localhost"
fi

# Create basic stunnel config if not exists
if [ ! -f /etc/stunnel/stunnel.conf ]; then
cat > /etc/stunnel/stunnel.conf <<EOF
client = no
[ssh]
accept = 443
connect = 22
cert = /etc/stunnel/stunnel.pem
EOF
fi

# Enable and restart stunnel
if command -v systemctl &>/dev/null; then
    systemctl enable stunnel4
    systemctl restart stunnel4
fi

# Menu function
while true; do
    echo "==========================="
    echo " SSH & Stunnel Management"
    echo "==========================="
    echo "1) Create SSH User"
    echo "2) List SSH Users"
    echo "3) Delete SSH User"
    echo "4) Exit"
    read -p "Choose option: " opt

    case $opt in
        1)
            read -p "Enter username: " u
            read -sp "Enter password: " p && echo
            useradd -m "$u" -s /bin/bash
            echo "$u:$p" | chpasswd
            echo "User $u created successfully."
            ;;
        2)
            cut -d: -f1 /etc/passwd
            ;;
        3)
            read -p "Enter username to delete: " u
            userdel -r "$u"
            echo "User $u deleted."
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
done
