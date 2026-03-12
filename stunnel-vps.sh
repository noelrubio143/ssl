#!/bin/bash
# Stunnel VPS Menu Script
# Compatible with Debian/Ubuntu

set -e

STUNNEL_CONF="/etc/stunnel/stunnel.conf"
STUNNEL_CERT="/etc/stunnel/stunnel.pem"

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi
}

install_stunnel() {
    echo "[*] Installing Stunnel..."
    apt update -y
    apt install stunnel4 -y
    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
    echo "[+] Stunnel installed!"
}

generate_ssl() {
    echo "[*] Generating SSL certificate..."
    mkdir -p /etc/stunnel
    openssl req -new -x509 -days 3650 -nodes -out $STUNNEL_CERT -keyout $STUNNEL_CERT -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=example.com"
    chmod 600 $STUNNEL_CERT
    echo "[+] SSL certificate created at $STUNNEL_CERT"
}

configure_stunnel() {
    read -p "Enter the service to forward (example: ssh): " SERVICE
    read -p "Enter the local port to connect (example: 22): " LOCAL_PORT
    read -p "Enter the external port Stunnel will listen on (example: 443): " EXTERNAL_PORT

    cat > $STUNNEL_CONF <<EOF
cert = $STUNNEL_CERT
pid = /var/run/stunnel.pid
client = no

[$SERVICE]
accept = $EXTERNAL_PORT
connect = $LOCAL_PORT
EOF

    echo "[+] Stunnel configured!"
}

start_stunnel() {
    systemctl restart stunnel4
    systemctl enable stunnel4
    echo "[+] Stunnel started and enabled at boot!"
}

stop_stunnel() {
    systemctl stop stunnel4
    echo "[+] Stunnel stopped!"
}

status_stunnel() {
    systemctl status stunnel4
}

menu() {
    clear
    echo "=============================="
    echo "     Stunnel VPS Menu"
    echo "=============================="
    echo "1) Install Stunnel"
    echo "2) Generate SSL Certificate"
    echo "3) Configure Stunnel"
    echo "4) Start Stunnel"
    echo "5) Stop Stunnel"
    echo "6) Check Stunnel Status"
    echo "0) Exit"
    echo "=============================="
    read -p "Choose an option: " choice

    case $choice in
        1) install_stunnel ;;
        2) generate_ssl ;;
        3) configure_stunnel ;;
        4) start_stunnel ;;
        5) stop_stunnel ;;
        6) status_stunnel ;;
        0) exit 0 ;;
        *) echo "Invalid option!" ;;
    esac
    read -p "Press Enter to continue..." 
    menu
}

check_root
menu
