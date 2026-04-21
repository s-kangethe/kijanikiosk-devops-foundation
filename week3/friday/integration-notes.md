Challenge A: ProtectSystem=strict and the EnvironmentFile
I used:
kk-api.service → /opt/kijanikiosk/config/api.env
kk-payments.service → /opt/kijanikiosk/config/payments-api.env

which are fully compatible with ProtectSystem=strict, clean /opt isolation and production safe design

Challenge B: The Monitoring User and ACL Defaults
The conflict in Challenge B was that the new /opt/kijanikiosk/health directory was not part of the original access model, yet it needed to support both root-based provisioning writes and non-root reads by Amina and monitoring users. This created a mismatch between ownership, writers, and readers, causing permission failures despite correct setup. I considered using broader permissions, /etc-based configuration, or an ACL + group-based model. I chose the ACL and dedicated kijani-monitor group approach for security and scalability. I implemented setgid ownership, group membership for services and users, and ACL defaults to ensure inherited access. This preserved strict system isolation while enabling secure shared access without sudo

Challenge C: logrotate postrotate and PrivateTmp
The conflict in Challenge C was between the log rotation mechanism and a misconfigured systemd service for kk-logs, rather than the logging lifecycle itself. While logrotate was correctly applied to /opt/kijanikiosk/shared/logs and configured to restart the service after rotation, the kk-logs unit failed repeatedly because it referenced an unset environment variable (PORT). This caused the service to crash on startup with an invalid argument error, triggering systemd’s restart limit and breaking the intended postrotate flow. I initially investigated log lifecycle handling (reload vs restart vs signal-based approaches), but the root cause was actually upstream in service configuration. I resolved the issue by removing the undefined variable dependency and hardcoding a valid port in ExecStart, ensuring the service could start reliably. This stabilized the systemd unit, allowing logrotate’s postrotate restart to function safely and restoring consistent log rotation without entering a failure loop.
