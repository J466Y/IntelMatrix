#!/bin/bash
set -e  # Stops the script if errors

# Common errors Mongodb
echo "> Checking that mongodb has no errors"
sudo rm -f /tmp/mongodb-27017.sock
sudo mkdir -p /var/log/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chmod -R 755 /var/log/mongodb
sudo systemctl restart mongod

echo "> Waiting for MongoDB to start..."
until mongosh --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; do
  sleep 1
done
echo "  > MongoDB is UP!"

# URI MongoDB
MONGO_URI=${MONGO_URI:-"mongodb://127.0.0.1:27017/DBleaks"}

echo "> Creating python venv..."
python3 -m venv venv

echo "> Installing Python dependencies..."
venv/bin/pip install --no-cache-dir -r requirements.txt

echo "> Configuring MongoDB indexes and collections..."
mongosh "$MONGO_URI" --eval "db.credentials.createIndex({\"l\":\"hashed\"})"
mongosh "$MONGO_URI" --eval "db.credentials.createIndex({\"url\":\"hashed\"})"
mongosh "$MONGO_URI" --eval "db.credentials.createIndex({\"leakname\":1, \"date\":1})"

# Create indexes
mongosh "$MONGO_URI" --eval "db.phone_numbers.createIndex({\"l\":\"hashed\"})"
mongosh "$MONGO_URI" --eval "db.phone_numbers.createIndex({\"phone\":1})"
mongosh "$MONGO_URI" --eval "db.miscfiles.createIndex({\"l\":\"hashed\"})"
mongosh "$MONGO_URI" --eval "db.miscfiles.createIndex({\"donnee\":1})"

# Create collections
mongosh "$MONGO_URI" --eval "db.createCollection(\"leaks\")"
mongosh "$MONGO_URI" --eval "db.createCollection(\"phone_numbers\")"
mongosh "$MONGO_URI" --eval "db.createCollection(\"miscfiles\")"

echo "> Creating initial users..."
./venv/bin/python init.py

echo ">> Setup completed successfully!"

echo "> Checking intelmatrix service..."
SERVICE_NAME="intelmatrix"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
APP_DIR=$(pwd)
APP_USER=${SUDO_USER:-$USER}

if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "  > Service $SERVICE_NAME is already running."
else
    echo "  > Creating and starting systemd service: $SERVICE_NAME ..."
    sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=IntelMatrix (Leaky) Service
After=network.target mongod.service

[Service]
Type=simple
User=$APP_USER
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/venv/bin/python $APP_DIR/scraper.py --service
Restart=always

[Install]
WantedBy=multi-user.target
EOF"
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
    sudo systemctl start "$SERVICE_NAME"
    echo "  > Service $SERVICE_NAME created and started."
fi
