#!/bin/bash

# -----------------------------
# Update system
# -----------------------------
apt update -y
apt upgrade -y

# -----------------------------
# Install basic tools
# -----------------------------
apt install -y wget curl tar software-properties-common

# -----------------------------
# Install Node Exporter
# -----------------------------
cd /opt
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.8.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.8.1.linux-amd64.tar.gz

# Create node_exporter user
useradd --no-create-home --shell /bin/false node_exporter

# Move binary
cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/

# Create systemd service
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Start Node Exporter
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# -----------------------------
# Install Prometheus
# -----------------------------
cd /opt
wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-2.53.0.linux-amd64.tar.gz
tar -xvf prometheus-2.53.0.linux-amd64.tar.gz

# Create Prometheus user
useradd --no-create-home --shell /bin/false prometheus

# Create directories
mkdir /etc/prometheus
mkdir /var/lib/prometheus

# Move files
cp prometheus-2.53.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.53.0.linux-amd64/promtool /usr/local/bin/
cp -r prometheus-2.53.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.53.0.linux-amd64/console_libraries /etc/prometheus

# Set permissions
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus

# Create config file
cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
EOF

# Create systemd service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=default.target
EOF

# Start Prometheus
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

# -----------------------------
# Install Grafana
# -----------------------------
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list

apt update -y
apt install grafana -y

# Start Grafana
systemctl enable grafana
systemctl start grafana

# -----------------------------
# Final Info
# -----------------------------
echo "Setup Complete"
echo "Grafana: http://<EC2-IP>:3000 (admin/admin)"
echo "Prometheus: http://<EC2-IP>:9090"
echo "Node Exporter: http://<EC2-IP>:9100/metrics"
