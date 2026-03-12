#!/bin/bash

# --- Automatic Stunnel & dependencies setup ---
PKG_INSTALL=""
command -v pkg &>/dev/null && PKG_INSTALL="pkg install -y" || command -v apt &>/dev/null && PKG_INSTALL="apt update && apt install -y"
command -v stunnel >/dev/null 2>&1 || $PKG_INSTALL stunnel4 openssl
[ ! -f /etc/stunnel/stunnel.pem ] && openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/CN=localhost"
[ ! -f /etc/stunnel/stunnel.conf ] && echo -e "client = no\n[ssh]\naccept = 443\nconnect = 22\ncert = /etc/stunnel/stunnel.pem" > /etc/stunnel/stunnel.conf
command -v systemctl >/dev/null 2>&1 && systemctl enable stunnel4 && systemctl restart stunnel4

# --- Kusang nag-run na etype menu ---
while true; do
    echo
    echo "1) Create SSH User"
    echo "2) List SSH Users"
    echo "3) Delete SSH User"
    echo "4) Exit"
    read -p "Choice: " opt

    case $opt in
        1)
            read -p "Username: " u
            read -sp "Password: " p && echo
            useradd -m "$u" -s /bin/bash
            echo "$u:$p" | chpasswd
            echo "User $u created."
            ;;
        2)
            cut -d: -f1 /etc/passwd
            ;;
        3)
            read -p "Username to delete: " u
            userdel -r "$u"
            echo "User $u deleted."
            ;;
        4)
            exit
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
