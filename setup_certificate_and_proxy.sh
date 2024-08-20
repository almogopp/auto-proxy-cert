#!/bin/bash

# Certificate file name (modify as needed)
CERTIFICATE_FILE="proxy_cert.crt"

# Certificate content
CERTIFICATE_CONTENT="-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJANUE9xEjw0nBMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAklMMQswCQYDVQQIDAJDQTEPMA0GA1UEBwwGTmV0YW55MQ4wDAYDVQQKDAVO
ZXRhbnkxETAPBgNVBAMMCE15Q2VydENBMB4XDTE3MDEwMTAwMDAwMFoXDTI3MDEw
MTAwMDAwMFowRTELMAkGA1UEBhMCSUwxCzAJBgNVBAgMAkNBMQ8wDQYDVQQHDAZO
ZXRhbnkxDjAMBgNVBAoMBU5ldGFueTERMA8GA1UEAwwITXlDZXJ0Q0EwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCr1HzliBRN7mFH0sHlQHQzCGwXr0Qa
...
-----END CERTIFICATE-----"

# Write the certificate content to a file
echo "$CERTIFICATE_CONTENT" > "$CERTIFICATE_FILE"

# Check if the certificate file was created successfully
if [ ! -f "$CERTIFICATE_FILE" ]; then
    echo "Failed to create certificate file!"
    exit 1
fi

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unable to detect the operating system."
    exit 1
fi

# Handle according to the operating system type
case "$OS" in
    ubuntu)
        CERT_DIR="/usr/local/share/ca-certificates"
        sudo cp "$CERTIFICATE_FILE" "$CERT_DIR/"
        sudo update-ca-certificates
        ;;
    rhel|centos|fedora)
        CERT_DIR="/etc/pki/ca-trust/source/anchors"
        sudo cp "$CERTIFICATE_FILE" "$CERT_DIR/"
        sudo update-ca-trust extract
        ;;
    *)
        echo "The operating system $OS is not supported by this script."
        exit 1
        ;;
esac

echo "The certificate was successfully added."

# Ask for proxy URL from the user
read -p "Enter proxy URL (e.g., http://proxy.example.com:8080): " PROXY_URL

# Get machine IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Get the network segment (assuming a /24 subnet, modify if needed)
NETWORK_SEGMENT=$(echo "$IP_ADDRESS" | sed 's/\.[0-9]*$/.0\/24/')

# Set default no_proxy values
NO_PROXY="localhost,127.0.0.1,$IP_ADDRESS,$NETWORK_SEGMENT"

# Ask for additional no_proxy domains from the user
read -p "Enter additional no_proxy domains (comma-separated, or leave blank): " ADDITIONAL_NO_PROXY

# Combine default and additional no_proxy values
if [ -n "$ADDITIONAL_NO_PROXY" ]; then
    NO_PROXY="$NO_PROXY,$ADDITIONAL_NO_PROXY"
fi

# Set proxy environment variables
export http_proxy="$PROXY_URL"
export https_proxy="$PROXY_URL"
export ftp_proxy="$PROXY_URL"
export no_proxy="$NO_PROXY"

# Optional: Persist proxy settings for future sessions
echo "export http_proxy=\"$PROXY_URL\"" | sudo tee -a /etc/environment
echo "export https_proxy=\"$PROXY_URL\"" | sudo tee -a /etc/environment
echo "export ftp_proxy=\"$PROXY_URL\"" | sudo tee -a /etc/environment
echo "export no_proxy=\"$NO_PROXY\"" | sudo tee -a /etc/environment

# Update the system
case "$OS" in
    ubuntu)
        sudo apt update && sudo apt upgrade -y
        ;;
    rhel|centos|fedora)
        sudo yum update -y
        ;;
esac

echo "Proxy settings configured, and the system has been updated."
