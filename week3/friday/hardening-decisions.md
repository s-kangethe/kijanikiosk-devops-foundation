# Hardening Decisions for Nia

The production server was hardened using controls verified on the live environment after deployment. The objective was to reduce avoidable business risk while preserving service availability for customers and internal teams. Current evidence shows the payments component remains healthy after hardening and now operates at a measured low exposure level of 1.4, while both customer-facing services report healthy status. This indicates that risk reduction measures were applied without interrupting core operations.

The first decision was to separate service identities for the application, payments, and logging functions. Each component operates under its own controlled identity rather than sharing broad administrator privileges. This reduces the chance that compromise of one component automatically grants access to every other component. It also improves accountability because actions can be traced to a specific service boundary.

The second decision was to restrict public network exposure of the payments capability. Current firewall rules allow normal website traffic and administrative access, while the payments function is blocked from general public access and only available through approved internal paths. This reduces the likelihood of unauthorized connection attempts, automated internet scanning, and accidental direct exposure of sensitive functionality.

The third decision was to tighten access to configuration data. Sensitive operational settings are stored in a restricted area that is not openly accessible to all users on the server. This lowers the risk of accidental disclosure of secrets, credentials, or service settings that could help an attacker move further into the environment.

The fourth decision was to enforce least privilege at runtime. The payments component operates with materially reduced privileges and a constrained execution model. In practical terms, it cannot freely elevate access, inspect unrelated processes, or perform broad administrative actions. This reduces the impact of a successful exploit because the compromised process would still face significant operating limits.

The fifth decision was to make core operating system areas read-only to the payments component during execution. This means the service can perform its business purpose without having broad ability to alter the host environment. The main risk mitigated is persistence after compromise, where malicious code attempts to modify the server so it survives reboots or hides within system areas.

The sixth decision was to isolate temporary working space and hardware access. Temporary storage used by the payments component is separated from other workloads, and unnecessary device access is restricted. This lowers the chance of data crossover between services and reduces misuse of host resources not required for normal operation.

The seventh decision was to improve resilience through automatic recovery and health reporting. Services are configured to restart after qualifying failures, and health status is written in a structured format that confirms the application and payments functions are operational. This reduces customer-facing downtime and shortens the time required to detect service degradation.

The eighth decision was to preserve operational evidence while controlling storage growth. Logging retention controls were enabled so records remain available for troubleshooting and incident review, while storage limits reduce the chance that logs consume excessive disk space. This balances operational visibility with platform stability.

The ninth decision was to limit unnecessary communication paths for the payments component. Runtime controls narrow the types of network communication the service may use and favor only approved local interactions required for operation. This reduces the chance of misuse for lateral movement, data exfiltration, or unauthorized outbound communication if the component were compromised.

| Control | What it does | Risk mitigated |
|---|---|---|
| Separate service identities | Runs core functions under different identities | Lateral movement after compromise |
| Firewall segmentation | Blocks broad public access to payments capability | Unauthorized internet access |
| Restricted configuration access | Limits readers of sensitive settings | Credential or secret leakage |
| Least privilege runtime model | Reduces what the service can do if exploited | Privilege escalation |
| Read-only host areas | Prevents broad system modification during runtime | Persistence and tampering |
| Isolated temporary workspace | Separates temporary data between workloads | Cross-service data leakage |
| Automatic restart and health checks | Restores failed services and reports status | Extended outage and slow detection |
| Logging retention controls | Preserves evidence within storage limits | Lost evidence or disk exhaustion |
| Restricted communication scope | Narrows permitted network behavior | Exfiltration and lateral movement |

The current posture does not fully protect against defects in application code, stolen administrator credentials, insider misuse by approved users, phishing attacks, upstream supply-chain compromise, or previously unknown software vulnerabilities. It also does not replace the need for tested backups, patch management, staff awareness, broader monitoring, and incident response readiness. These areas require continuing operational controls beyond server hardening alone.
