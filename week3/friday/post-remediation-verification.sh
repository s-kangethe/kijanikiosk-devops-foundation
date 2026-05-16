#!/bin/bash

sudo logrotate -f /etc/logrotate.conf

sudo -u kk-api touch /opt/kijanikiosk/shared/logs/test-write.tmp \
  && echo "PASS: kk-api can write after logrotate" \
  || echo "FAIL: kk-api cannot write to shared/logs"
