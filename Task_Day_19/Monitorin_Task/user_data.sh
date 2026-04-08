#!/bin/bash
set -xe

exec > /var/log/user-data.log 2>&1

echo "STARTING SETUP"

# Update system
apt update -y
apt install -y wget curl tar software-properties-common

cd /opt

# =========================
# Install Node Exporter
# =========================

NODE_VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')

wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/node_exporter-${NODE_VERSION}.linux-amd64.tar.gz

tar -xvf node_exporter-${NODE_VERSION}.linux-amd64.tar.gz

cp node_exporter-${NODE_VERSION}.linux-amd64/node_exporter /usr/local/bin/

# Create service
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# =========================
# Install Prometheus
# =========================

PROM_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')

wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

tar -xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

cp prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
cp prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/

mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
EOF

# Create service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# =========================
# Install Grafana
# =========================

wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list

apt update -y
apt install -y grafana

# =========================
# Start Services
# =========================

systemctl daemon-reload

systemctl enable node_exporter
systemctl start node_exporter

systemctl enable prometheus
systemctl start prometheus

systemctl enable grafana-server
systemctl start grafana-server

echo "SETUP COMPLETE"
