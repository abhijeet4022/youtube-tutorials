#!/bin/bash

# webserver_setup.sh
# Run this script as root or with sudo

# Exit on any error
set -e

# Function to display a message
echo_info() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

echo_info "Setting up Apache Web Server with HTTPS..."

# Step 1: Install required packages
echo_info "Installing Apache, OpenSSL, and mod_ssl..."
dnf install httpd mod_ssl openssl -y
systemctl restart httpd

# Step 2: Create a dummy webpage
echo_info "Creating a dummy webpage..."
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Website</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>This is my test webpage running on CentOS 9.</p>
</body>
</html>
EOF

# Step 3: Generate SSL certificate (non-interactive)
echo_info "Generating a self-signed SSL certificate..."
IP_ADDRESS=$(hostname -I | awk '{print $1}')
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/pki/tls/private/apache-selfsigned.key \
-out /etc/pki/tls/certs/apache-selfsigned.crt \
-subj "/C=IN/ST=Jharkhand/L=Jamshedpur/O=Organization/CN=$IP_ADDRESS"

# Step 4: Update SSL configuration
echo_info "Updating SSL configuration..."
sed -i 's|^SSLCertificateFile.*|SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt|' /etc/httpd/conf.d/ssl.conf
sed -i 's|^SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key|' /etc/httpd/conf.d/ssl.conf

# Step 5: Redirect HTTP to HTTPS
echo_info "Configuring HTTP to HTTPS redirection..."
cat > /etc/httpd/conf.d/http-to-https.conf << EOF
<VirtualHost *:80>
    ServerName $IP_ADDRESS
    Redirect permanent / https://$IP_ADDRESS/
</VirtualHost>
EOF

# Step 6: Configure the firewall
echo_info "Configuring the firewall..."
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Step 7: Start and enable Apache
echo_info "Starting and enabling Apache..."
systemctl restart httpd
systemctl enable httpd

# Completion message
echo_info "Setup complete! Access your website at:"
echo_info "HTTP:  http://$IP_ADDRESS"
echo_info "HTTPS: https://$IP_ADDRESS"

