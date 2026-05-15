kangethe@StacyKangethe:~/kijanikiosk-devops-foundation/week4/friday/ansible/templates$ cat kk-payments.service.j2
[Unit]
Description=KK Payments Service
After=network.target

[Service]
User=kk-payments
ExecStart=/usr/bin/sleep infinity

Restart=always

NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes

ReadWritePaths=/opt/kijanikiosk

[Install]
WantedBy=multi-user.target
kangethe@StacyKangethe:~/kijanikiosk-devops-foundation/week4/friday/ansible/templates$ systemd-analyze security kk-payments.service
  NAME                                                        DESCRIPTION                                                                    >
✓ SystemCallFilter=~@swap                                     System call allow list defined for service, and @swap is not included          >
✗ SystemCallFilter=~@resources                                System call allow list defined for service, and @resources is included (e.g. io>
✓ SystemCallFilter=~@reboot                                   System call allow list defined for service, and @reboot is not included        >
✓ SystemCallFilter=~@raw-io                                   System call allow list defined for service, and @raw-io is not included        >
✗ SystemCallFilter=~@privileged                               System call allow list defined for service, and @privileged is included (e.g. c>
✓ SystemCallFilter=~@obsolete                                 System call allow list defined for service, and @obsolete is not included      >
✓ SystemCallFilter=~@mount                                    System call allow list defined for service, and @mount is not included         >
✓ SystemCallFilter=~@module                                   System call allow list defined for service, and @module is not included        >
✓ SystemCallFilter=~@debug                                    System call allow list defined for service, and @debug is not included         >
✓ SystemCallFilter=~@cpu-emulation                            System call allow list defined for service, and @cpu-emulation is not included >
✓ SystemCallFilter=~@clock                                    System call allow list defined for service, and @clock is not included         >
✓ RemoveIPC=                                                  Service user cannot leave SysV IPC objects around                              >
✗ RootDirectory=/RootImage=                                   Service runs within the host's root directory                                  >
✓ User=/DynamicUser=                                          Service runs under a static non-root user identity                             >
✓ RestrictRealtime=                                           Service realtime scheduling access is restricted                               >
✓ CapabilityBoundingSet=~CAP_SYS_TIME                         Service processes cannot change the system clock                               >
✓ NoNewPrivileges=                                            Service processes cannot acquire new privileges                                >
✓ AmbientCapabilities=                                        Service process does not receive ambient capabilities                          >
✓ CapabilityBoundingSet=~CAP_BPF                              Service may load BPF programs                                                  >
✓ SystemCallArchitectures=                                    Service may execute system calls only with native ABI                          >
✗ RestrictAddressFamilies=~AF_UNIX                            Service may allocate local sockets                                             >
✗ RestrictAddressFamilies=~AF_(INET|INET6)                    Service may allocate Internet sockets                                          >
✓ ProtectSystem=                                              Service has strict read-only access to the OS file hierarchy                   >
✓ ProtectProc=                                                Service has restricted access to process tree (/proc hidepid=)                 >
✓ SupplementaryGroups=                                        Service has no supplementary groups                                            >
✓ CapabilityBoundingSet=~CAP_SYS_RAWIO                        Service has no raw I/O access                                                  >
✓ CapabilityBoundingSet=~CAP_SYS_PTRACE                       Service has no ptrace() debugging abilities                                    >
✓ CapabilityBoundingSet=~CAP_SYS_(NICE|RESOURCE)              Service has no privileges to change resource use parameters                    >
✓ CapabilityBoundingSet=~CAP_NET_ADMIN                        Service has no network configuration privileges                                >
✓ CapabilityBoundingSet=~CAP_NET_(BIND_SERVICE|BROADCAST|RAW) Service has no elevated networking privileges                                  >
✓ CapabilityBoundingSet=~CAP_AUDIT_*                          Service has no audit subsystem access                                          >
✓ CapabilityBoundingSet=~CAP_SYS_ADMIN                        Service has no administrator privileges                                        >
✓ PrivateTmp=                                                 Service has no access to other software's temporary files                      >
✓ ProcSubset=                                                 Service has no access to non-process /proc files (/proc subset=)               >
✓ CapabilityBoundingSet=~CAP_SYSLOG                           Service has no access to kernel logging                                        >
✓ ProtectHome=                                                Service has no access to home directories                                      >
✓ PrivateDevices=                                             Service has no access to hardware devices                                      >
✗ PrivateNetwork=                                             Service has access to the host's network                                       >
✗ PrivateUsers=                                               Service has access to other users                                              >
✗ DeviceAllow=                                                Service has a device ACL with some special devices: char-rtc:r                 >
✓ KeyringMode=                                                Service doesn't share key material with other services                         >
✓ Delegate=                                                   Service does not maintain its own delegated control group subtree              >
✗ IPAddressDeny=                                              Service defines IP address allow list with non-localhost entries               >
✓ NotifyAccess=                                               Service child processes cannot alter service state                             >
✓ ProtectClock=                                               Service cannot write to the hardware clock or system clock                     >
✓ CapabilityBoundingSet=~CAP_SYS_PACCT                        Service cannot use acct()                                                      >
✓ CapabilityBoundingSet=~CAP_KILL                             Service cannot send UNIX signals to arbitrary processes                        >
✓ ProtectKernelLogs=                                          Service cannot read from or write to the kernel log ring buffer                >
✓ CapabilityBoundingSet=~CAP_WAKE_ALARM                       Service cannot program timers that wake up the system                          >
✓ CapabilityBoundingSet=~CAP_(DAC_*|FOWNER|IPC_OWNER)         Service cannot override UNIX file/IPC permission checks                        >
✓ ProtectControlGroups=                                       Service cannot modify the control group file system                            >
✓ CapabilityBoundingSet=~CAP_LINUX_IMMUTABLE                  Service cannot mark files immutable                                            >
✓ CapabilityBoundingSet=~CAP_IPC_LOCK                         Service cannot lock memory into RAM                                            >
✓ ProtectKernelModules=                                       Service cannot load or read kernel modules                                     >
✓ CapabilityBoundingSet=~CAP_SYS_MODULE                       Service cannot load kernel modules                                             >
✓ CapabilityBoundingSet=~CAP_SYS_TTY_CONFIG                   Service cannot issue vhangup()                                                 >
✓ CapabilityBoundingSet=~CAP_SYS_BOOT                         Service cannot issue reboot()                                                  >
✓ CapabilityBoundingSet=~CAP_SYS_CHROOT                       Service cannot issue chroot()                                                  >
✓ PrivateMounts=                                              Service cannot install system mounts                                           >
✓ CapabilityBoundingSet=~CAP_BLOCK_SUSPEND                    Service cannot establish wake locks                                            >
✓ MemoryDenyWriteExecute=                                     Service cannot create writable executable memory mappings                      >
✓ RestrictNamespaces=~user                                    Service cannot create user namespaces                                          >
✓ RestrictNamespaces=~pid                                     Service cannot create process namespaces                                       >
✓ RestrictNamespaces=~net                                     Service cannot create network namespaces                                       >
✓ RestrictNamespaces=~uts                                     Service cannot create hostname namespaces                                      >
✓ RestrictNamespaces=~mnt                                     Service cannot create file system namespaces                                   >
✓ CapabilityBoundingSet=~CAP_LEASE                            Service cannot create file leases                                              >
✓ CapabilityBoundingSet=~CAP_MKNOD                            Service cannot create device nodes                                             >
✓ RestrictNamespaces=~cgroup                                  Service cannot create cgroup namespaces                                        >
✓ RestrictNamespaces=~ipc                                     Service cannot create IPC namespaces                                           >
✓ ProtectHostname=                                            Service cannot change system host/domainname                                   >
✓ CapabilityBoundingSet=~CAP_(CHOWN|FSETID|SETFCAP)           Service cannot change file ownership/access mode/capabilities                  >
✓ CapabilityBoundingSet=~CAP_SET(UID|GID|PCAP)                Service cannot change UID/GID identities/capabilities                          >
✓ LockPersonality=                                            Service cannot change ABI personality                                          >
✓ ProtectKernelTunables=                                      Service cannot alter kernel tunables (/proc/sys, …)                            >
✓ RestrictAddressFamilies=~AF_PACKET                          Service cannot allocate packet sockets                                         >
✓ RestrictAddressFamilies=~AF_NETLINK                         Service cannot allocate netlink sockets                                        >
✓ RestrictAddressFamilies=~…                                  Service cannot allocate exotic sockets                                         >
✓ CapabilityBoundingSet=~CAP_MAC_*                            Service cannot adjust SMACK MAC                                                >
✓ RestrictSUIDSGID=                                           SUID/SGID file creation by service is restricted                               >
✓ UMask=                                                      Files created by service are accessible only by service's own user by default  >

→ Overall exposure level for kk-payments.service: 1.4 OK 🙂

kangethe@StacyKangethe:~/kijanikiosk-devops-foundation/week4/friday/ansible/templates$ gnome-screenshot
kangethe@StacyKangethe:~/kijanikiosk-devops-foundation/week4/friday/ansible/templates$ systemctl status kk-payments
● kk-payments.service - kk-payments
     Loaded: loaded (/etc/systemd/system/kk-payments.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-05-15 10:15:31 EAT; 7h ago
   Main PID: 2448 (python3)
      Tasks: 1 (limit: 18552)
     Memory: 9.5M (peak: 9.8M)
        CPU: 4.096s
     CGroup: /system.slice/kk-payments.service
             └─2448 /usr/bin/python3 -m http.server 3001

May 15 10:15:31 StacyKangethe systemd[1]: Started kk-payments.service - kk-payments.
