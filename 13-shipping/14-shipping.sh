#!/bin/bash

# --- Configuration Variables (from Ansible 'vars') ---
MYSQL_HOST="mysql.stallions.space"
CART_HOST="cart.app.stallions.space"
APP_USER="roboshop"
APP_DIR="/app"
NEW_DB_PASS="RoboShop@1" # Password for application users

# --- Safety Check: Ensure the script is run as root ---
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

echo ">>> Starting Shipping Service Installation..."

# --- Task: Ensure Python 3 is installed (from 'pre_tasks') ---
echo "--> Ensuring Python 3 is installed (ignoring errors if already present)..."
yum install -y python3 &>/dev/null

# --- Task: Install prerequisite packages ---
echo "--> Installing prerequisite packages: EPEL, Maven, MySQL client, and Unzip..."
#
# *** FIX IS HERE: Added 'unzip' to the package list ***
#
yum install -y epel-release maven mysql python3-PyMySQL unzip

# --- Task: Create Roboshop application user ---
echo "--> Creating application user '$APP_USER'..."
id -u $APP_USER &>/dev/null || useradd -r -s /bin/nologin $APP_USER

# --- Task: Ensure /app directory exists ---
echo "--> Creating application directory '$APP_DIR'..."
mkdir -p "$APP_DIR"
chown "$APP_USER:$APP_USER" "$APP_DIR"

# --- Task: Download and unpack shipping artifact ---
echo "--> Downloading and unpacking shipping application..."
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
unzip -o /tmp/shipping.zip -d "$APP_DIR"
chown -R "$APP_USER:$APP_USER" "$APP_DIR"
rm -f /tmp/shipping.zip

# --- Task: Build application with Maven ---
echo "--> Building application with Maven (this may take a moment)..."
(cd "$APP_DIR" && mvn clean package)

# --- Task: Create shipping systemd service file ---
echo "--> Creating systemd service file for shipping..."
cat > /etc/systemd/system/shipping.service <<EOF
[Unit]
Description=Shipping Service

[Service]
User=${APP_USER}
Environment="CART_ENDPOINT=${CART_HOST}:8080"
Environment="DB_HOST=${MYSQL_HOST}"
Environment="DB_USER=shipping"
Environment="DB_PASS=${NEW_DB_PASS}"
ExecStart=/usr/bin/java -jar ${APP_DIR}/target/shipping-1.0.jar
SyslogIdentifier=shipping

[Install]
WantedBy=multi-user.target
EOF

# --- Database Schema Loading ---
echo "--> Loading application database schema..."
mysql -h "${MYSQL_HOST}" -u"${APP_USER}" -p"${NEW_DB_PASS}" < "${APP_DIR}/db/schema.sql" 2>/dev/null

echo "--> Renaming 'cities' table to 'codes'..."
mysql -h "${MYSQL_HOST}" -u"${APP_USER}" -p"${NEW_DB_PASS}" cities -e 'RENAME TABLE cities TO codes;' 2>/dev/null

echo "--> Loading master data into the database..."
mysql -h "${MYSQL_HOST}" -u"${APP_USER}" -p"${NEW_DB_PASS}" cities < "${APP_DIR}/db/master-data.sql" 2>/dev/null

# --- Handler: Reload and restart shipping ---
echo "--> Reloading systemd, enabling and restarting the shipping service..."
systemctl daemon-reload
systemctl enable shipping
systemctl restart shipping

echo ">>> Shipping Service installation and configuration complete!"