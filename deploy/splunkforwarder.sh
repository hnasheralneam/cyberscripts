#!/bin/sh
# Deploy Splunk Forwarder
# Requires input in form of server IP
# Untested
# May not work with Alpine

if [ "$(id -u)" -ne 0 ]; then
  printf "This script requires root privileges. Exiting\n"
  exit 1
fi

SPLUNK_SERVER_IP=$1

if [ -z "$SPLUNK_SERVER_IP" ]; then
  printf "Error: Splunk Server IP is required.\n"
  printf "Usage: $0 <SERVER_IP>\n"
  exit 1
fi

# Prompt for admin password to match the Ansible secret variable
printf "Enter Splunk admin password: "
stty -echo
read ADMIN_PASSWORD
stty echo
printf "\n"

# Information
SPLUNK_VERSION="10.2.0"
SPLUNK_BUILD="d749cb17ea65"
SPLUNK_HOME="/opt/splunkforwarder"
DOWNLOAD_DIR="/tmp"
SPLUNK_GPG_KEY="https://docs.splunk.com/images/6/6b/SplunkPGPKey.pub"

# OS Detection
if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
   OS_FAMILY="RedHat"
elif command -v apt >/dev/null 2>&1; then
   OS_FAMILY="Debian"
elif command -v zypper >/dev/null 2>&1; then
   OS_FAMILY="OpenSUSE"
elif command -v apk >/dev/null 2>&1; then
   OS_FAMILY="Alpine"
else
   OS_FAMILY="Unknown"
fi

# Create splunk user and group (system user, creating home directory)
if ! getent group splunk >/dev/null; then
    groupadd splunk
fi
if ! id "splunk" >/dev/null 2>&1; then
    useradd -r -m -g splunk -s /bin/bash splunk
fi

# Determine Installer File
if [ "$OS_FAMILY" = "RedHat" ]; then
   SPLUNK_INSTALLER_FILE="splunkforwarder-$SPLUNK_VERSION-$SPLUNK_BUILD.x86_64.rpm"
elif [ "$OS_FAMILY" = "Debian" ]; then
   SPLUNK_INSTALLER_FILE="splunkforwarder-$SPLUNK_VERSION-$SPLUNK_BUILD-linux-amd64.deb"
else
   SPLUNK_INSTALLER_FILE="splunkforwarder-$SPLUNK_VERSION-$SPLUNK_BUILD-linux-amd64.tgz"
fi

SPLUNK_DOWNLOAD_URL="https://download.splunk.com/products/universalforwarder/releases/$SPLUNK_VERSION/linux/$SPLUNK_INSTALLER_FILE"

# Download Installer
curl -o "$DOWNLOAD_DIR/$SPLUNK_INSTALLER_FILE" "$SPLUNK_DOWNLOAD_URL"
chmod 0644 "$DOWNLOAD_DIR/$SPLUNK_INSTALLER_FILE"

# Package Installation
if [ "$OS_FAMILY" = "RedHat" ]; then
   curl -o "$DOWNLOAD_DIR/SplunkPGPKey.pub" "$SPLUNK_GPG_KEY"
   rpm --import "$DOWNLOAD_DIR/SplunkPGPKey.pub"
   yum install -y "$DOWNLOAD_DIR/$SPLUNK_INSTALLER_FILE"

elif [ "$OS_FAMILY" = "Debian" ]; then
   dpkg -i "$DOWNLOAD_DIR/$SPLUNK_INSTALLER_FILE"

else
   # Fallback to Tarball (Generic Linux)
   tar -xzf "$DOWNLOAD_DIR/$SPLUNK_INSTALLER_FILE" -C /opt/
fi

# Ensure Directory Ownership and Structure
mkdir -p "$SPLUNK_HOME/var/log/splunk" \
         "$SPLUNK_HOME/var/run" \
         "$SPLUNK_HOME/var/lib/splunk" \
         "$SPLUNK_HOME/etc/system/local"

chown -R splunk:splunk "$SPLUNK_HOME"
chmod 0755 "$SPLUNK_HOME/var/log/splunk" "$SPLUNK_HOME/var/run" "$SPLUNK_HOME/var/lib/splunk" "$SPLUNK_HOME/etc/system/local"

# Create user-seed.conf
cat <<EOF > "$SPLUNK_HOME/etc/system/local/user-seed.conf"
[user_info]
USERNAME = admin
PASSWORD = $ADMIN_PASSWORD
EOF
chown splunk:splunk "$SPLUNK_HOME/etc/system/local/user-seed.conf"
chmod 0600 "$SPLUNK_HOME/etc/system/local/user-seed.conf"

# Configure forwarding via outputs.conf
cat <<EOF > "$SPLUNK_HOME/etc/system/local/outputs.conf"
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = $SPLUNK_SERVER_IP:9997

[tcpout-server://$SPLUNK_SERVER_IP:9997]
EOF
chown splunk:splunk "$SPLUNK_HOME/etc/system/local/outputs.conf"
chmod 0600 "$SPLUNK_HOME/etc/system/local/outputs.conf"

# First-time Splunk startup and initialization
if [ ! -e "$SPLUNK_HOME/var/lib/splunk/kvstore" ]; then
    sudo -u splunk SPLUNK_HOME="$SPLUNK_HOME" "$SPLUNK_HOME/bin/splunk" start --accept-license --answer-yes --no-prompt --seed-passwd "$ADMIN_PASSWORD"
    sleep 20
    sudo -u splunk SPLUNK_HOME="$SPLUNK_HOME" "$SPLUNK_HOME/bin/splunk" stop
    sleep 10
fi

# Create systemd service file
cat <<EOF > /etc/systemd/system/splunkforwarder.service
[Unit]
Description=Splunk Universal Forwarder
After=network.target

[Service]
Type=simple
User=splunk
Group=splunk
ExecStart=$SPLUNK_HOME/bin/splunk _internal_launch_under_systemd
WorkingDirectory=$SPLUNK_HOME
KillMode=mixed
KillSignal=SIGINT
TimeoutStopSec=360
Restart=on-failure
RestartSec=10s
Environment="SPLUNK_HOME=$SPLUNK_HOME"
Environment="LD_LIBRARY_PATH="
LimitNOFILE=65536
LimitNPROC=16000

[Install]
WantedBy=multi-user.target
EOF

chmod 0644 /etc/systemd/system/splunkforwarder.service

# Enable and start service
systemctl daemon-reload
systemctl enable splunkforwarder
systemctl start splunkforwarder

# Wait for service to stabilize
sleep 15

# Verify forwarder connection
printf "\nVerifying forwarder status...\n"
sudo -u splunk "$SPLUNK_HOME/bin/splunk" list forward-server -auth "admin:$ADMIN_PASSWORD"
