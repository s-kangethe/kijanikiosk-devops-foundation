#!/usr/bin/env bash
set -euo pipefail

# ensure script runs as root
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

verify_service() {
  systemctl is-active --quiet "$1" || {
    echo "SERVICE FAILED: $1"
    exit 1
  }
}

# -----------------------------
# Logging system
# -----------------------------
log()  { echo "[$(date +%F' '%T)] $*"; }

# -----------------------------
# Global state tracking
# -----------------------------
FAILED=0

# -----------------------------
# Result helpers
# -----------------------------
pass() { log "PASS: $*"; }

fail() { log "FAIL: $*"; FAILED=1; }

# --- DRIFT PROTECTION FUNCTION (ADD HERE) ---
verify_package() {
  local pkg=$1
  local expected=$2
  local actual

  actual=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || true)

  if [[ -z "$actual" ]]; then
    echo "FATAL: $pkg is not installed"
    exit 1
  fi

  if [[ "$actual" != "$expected" ]]; then
    echo "FATAL: $pkg drift detected ($actual != $expected)"
    exit 1
  fi
}

# ==========================================================
# KijaniKiosk Production Provisioning Script
# Final Week 3 Submission Version
#
# Expected dirty-state from audit:
# - kk-api / kk-payments / kk-logs may already exist
# - kijanikiosk group may already exist
# - /opt/kijanikiosk/config may have insecure 777 perms
# - logs ACLs may be missing
# - ufw may be inactive
# - curl package may be held
# - directories may partially exist
# - kk-* services may not exist
# ==========================================================

log "PHASE 1 - Preflight Package Drift Check"

NGINX_EXPECTED="1.24.0-2ubuntu7.6"

INSTALLED=$(dpkg-query -W -f='${Version}' nginx 2>/dev/null || true)

if [[ -n "$INSTALLED" && "$INSTALLED" != "$NGINX_EXPECTED" ]]; then
  log "DRIFT DETECTED: nginx=$INSTALLED expected=$NGINX_EXPECTED"
  exit 1
fi

pass "Preflight package state OK"

log "PHASE 1 - Packages"

sudo apt-get update -y
sudo apt-mark hold nginx nginx-common
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx curl ufw acl logrotate python3

log "PHASE D - Package Drift Protection"

NGINX_EXPECTED="1.24.0-2ubuntu7.6"
DRIFT_LOG="/var/log/nginx-drift.log"

check_nginx_drift() {
  local actual

  actual=$(dpkg-query -W -f='${Version}' nginx 2>/dev/null || true)

  echo "$(date '+%F %T') nginx=$actual" | sudo tee -a "$DRIFT_LOG" > /dev/null

  if [[ "$actual" != "$NGINX_EXPECTED" ]]; then
    echo "$(date '+%F %T') DRIFT DETECTED: expected=$NGINX_EXPECTED actual=$actual" | sudo tee -a "$DRIFT_LOG"
    echo "FATAL: nginx version drift detected"
    exit 1
  fi
}

NGINX_INSTALLED=$(dpkg-query -W -f='${Version}' nginx 2>/dev/null || true)
NGINX_COMMON_INSTALLED=$(dpkg-query -W -f='${Version}' nginx-common 2>/dev/null || true)

log "Expected nginx: $NGINX_EXPECTED"
log "Installed nginx: ${NGINX_INSTALLED:-NOT_FOUND}"

# ---- HARD FAIL IF MISSING ----
if [[ -z "$NGINX_INSTALLED" ]]; then
  log "FAIL: nginx is not installed"
  exit 1
fi

# ---- DRIFT CHECK ----
if [[ "$NGINX_INSTALLED" != "$NGINX_EXPECTED" ]]; then
  log "FAIL: nginx version drift detected ($NGINX_INSTALLED != $NGINX_EXPECTED)"
  exit 1
fi

# ---- OPTIONAL COMMON PACKAGE CHECK ----
if [[ -n "$NGINX_COMMON_INSTALLED" && "$NGINX_COMMON_INSTALLED" != "$NGINX_EXPECTED" ]]; then
  log "FAIL: nginx-common version drift detected ($NGINX_COMMON_INSTALLED != $NGINX_EXPECTED)"
  exit 1
fi

pass "Package drift check passed"

# ==========================================================
log "PHASE 2 - Users & Groups"

sudo groupadd -f kijanikiosk

for user in kk-api kk-payments kk-logs; do
    if id "$user" >/dev/null 2>&1; then
        pass "$user already exists"
    else
        sudo useradd -r -s /usr/sbin/nologin -g kijanikiosk "$user"
        pass "$user created"
    fi
done


# ==========================================================
log "PHASE 3 - Directories & Permissions"

sudo mkdir -p /opt/kijanikiosk/{config,shared/logs,health}

sudo chown -R root:kijanikiosk /opt/kijanikiosk

sudo chmod 750 /opt/kijanikiosk
sudo chmod 750 /opt/kijanikiosk/config
sudo chmod 750 /opt/kijanikiosk/shared
sudo chmod 2770 /opt/kijanikiosk/shared/logs
sudo chmod 750 /opt/kijanikiosk/health

pass "Directory structure corrected"


# ==========================================================
log "PHASE 4 - ACL Model"

sudo setfacl -b /opt/kijanikiosk/shared/logs || true

sudo setfacl -m u:kk-api:rwx,u:kk-payments:rx,u:kk-logs:rwx \
/opt/kijanikiosk/shared/logs

sudo setfacl -d -m u:kk-api:rwx,u:kk-payments:rx,u:kk-logs:rwx \
/opt/kijanikiosk/shared/logs

pass "ACL permissions applied"


# ==========================================================
log "PHASE 5 - Environment Files"

echo "PORT=3100" | sudo tee /opt/kijanikiosk/config/api.env 
echo "PORT=3001" | sudo tee /opt/kijanikiosk/config/payments-api.env 
echo "PORT=3002" | sudo tee /opt/kijanikiosk/config/logs.env 

sudo chown root:kijanikiosk /opt/kijanikiosk/config/*.env
sudo chmod 640 /opt/kijanikiosk/config/*.env

pass "Environment files secured"


# ==========================================================
log "PHASE 6 - Firewall"

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22/tcp comment "SSH admin access"
sudo ufw allow 80/tcp comment "HTTP public traffic"

sudo ufw allow from 127.0.0.1 to any port 3001 comment "Loopback payments"
sudo ufw allow from 10.0.1.0/24 to any port 3001 comment "Monitoring subnet"

sudo ufw deny 3001 comment "Block public payments"

sudo ufw --force enable

pass "Firewall configured"


# ==========================================================
log "PHASE 7 - systemd Services"

cat <<EOF | sudo tee /etc/systemd/system/kk-api.service >/dev/null
[Unit]
Description=kk-api
After=network.target

[Service]
User=kk-api
EnvironmentFile=/opt/kijanikiosk/config/api.env
ExecStart=/usr/bin/python3 -m http.server \${PORT}
WorkingDirectory=/tmp
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
MemoryDenyWriteExecute=true
RestrictSUIDSGID=true
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


cat <<EOF | sudo tee /etc/systemd/system/kk-payments.service >/dev/null
[Unit]
Description=kk-payments
After=kk-api.service network-online.target
Wants=kk-api.service

[Service]
User=kk-payments
Group=kijanikiosk
EnvironmentFile=/opt/kijanikiosk/config/payments-api.env
ExecStart=/usr/bin/python3 -m http.server \${PORT}
WorkingDirectory=/tmp

NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
ProtectSystem=strict
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
ProtectClock=true
ProtectHostname=true
LockPersonality=true
MemoryDenyWriteExecute=true
RestrictNamespaces=true
RestrictRealtime=true
RestrictSUIDSGID=true
RemoveIPC=true
SystemCallArchitectures=native
UMask=0077

ReadWritePaths=/tmp

Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF


cat <<EOF | sudo tee /etc/systemd/system/kk-logs.service >/dev/null
[Unit]
Description=kk-logs
After=network.target

[Service]
User=kk-logs
EnvironmentFile=/opt/kijanikiosk/config/logs.env
ExecStart=/usr/bin/python3 -m http.server \${PORT}
WorkingDirectory=/opt/kijanikiosk/shared/logs

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
MemoryDenyWriteExecute=true
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable --now kk-api kk-payments kk-logs

pass "Services installed and started"


# ==========================================================
log "PHASE 8 - Logging"

sudo mkdir -p /var/log/journal

if grep -q "^#*SystemMaxUse=" /etc/systemd/journald.conf; then
    sudo sed -i 's/^#*SystemMaxUse=.*/SystemMaxUse=500M/' \
    /etc/systemd/journald.conf
else
    echo "SystemMaxUse=500M" | sudo tee -a \
    /etc/systemd/journald.conf >/dev/null
fi

sudo systemctl restart systemd-journald

cat <<EOF | sudo tee /etc/logrotate.d/kijanikiosk >/dev/null
/opt/kijanikiosk/shared/logs/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    su root kijanikiosk
    create 0664 kk-api kijanikiosk
    postrotate
        systemctl restart kk-logs.service >/dev/null 2>&1 || true
    endscript
}
EOF

sudo logrotate --debug /etc/logrotate.d/kijanikiosk >/dev/null

pass "Logging controls configured"


# ==========================================================
log "PHASE 9 - Health Check"

API_STATUS="down"
PAY_STATUS="down"

timeout 2 bash -c 'echo >/dev/tcp/127.0.0.1/3000' \
&& API_STATUS="ok" || true

timeout 2 bash -c 'echo >/dev/tcp/127.0.0.1/3001' \
&& PAY_STATUS="ok" || true

printf '{"timestamp":"%s","kk-api":"%s","kk-payments":"%s"}\n' \
"$(date -Is)" "$API_STATUS" "$PAY_STATUS" \
| sudo tee /opt/kijanikiosk/health/last-provision.json >/dev/null

sudo chown kk-logs:kijanikiosk \
/opt/kijanikiosk/health/last-provision.json

sudo chmod 640 \
/opt/kijanikiosk/health/last-provision.json

pass "Health file written"


# ==========================================================
log "PHASE 10 - Final Verification"

id kk-api >/dev/null 2>&1 \
&& pass "kk-api exists" || fail "kk-api missing"

systemctl is-enabled kk-payments >/dev/null 2>&1 \
&& pass "kk-payments enabled" || fail "payments disabled"

sudo test -f /etc/logrotate.d/kijanikiosk \
&& pass "logrotate present" || fail "logrotate missing"

sudo ufw status | grep -q "3001.*DENY" \
&& pass "payments blocked externally" || fail "firewall incorrect"

sudo test -f /opt/kijanikiosk/health/last-provision.json \
&& pass "health file exists" || fail "health file missing"

sudo systemd-analyze security kk-payments.service \
> kk-payments-security-score.txt || true

# ==========================================================
if [ "$FAILED" -eq 0 ]; then
    log "SUCCESS - Provisioning complete"
    exit 0
else
    log "FAILED - One or more checks failed"
    exit 1
fi

verify_package nginx "1.24.0-2ubuntu7.6"
