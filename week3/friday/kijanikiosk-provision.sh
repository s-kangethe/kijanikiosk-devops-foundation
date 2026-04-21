if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi
#!/usr/bin/env bash
set -euo pipefail

FAILED=0

log()  { echo "[$(date +%F' '%T)] $*"; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; FAILED=1; }

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

log "PHASE 1 - Packages"

sudo apt-get update -y

# Remove hold if curl is held
if apt-mark showhold | grep -q "^curl$"; then
    sudo apt-mark unhold curl
    pass "Removed curl hold"
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx curl ufw acl logrotate python3

pass "Packages installed"


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

echo "PORT=3000" | sudo tee /opt/kijanikiosk/config/api.env 
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
