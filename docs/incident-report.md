# Incident Response Report — SOC Home Lab - Ziyad Tariq / 445009783

## 1. Preparation
### 1.1 Lab Architecture
This project implements a mini SIEM prototype built on three isolated virtual machines, each with a different role:

1. **WAZUH (Red Hat Enterprise Linux):** The monitoring server. It collects, analyzes, and monitors logs forwarded from the other two machines, acting as the central SIEM.
2. **DC01 (Windows Server 2022):** The Domain Controller. It manages the Windows domain, including authentication, password policies, and DNS, making the lab representative of a real enterprise network.
3. **WKSTN01 (Windows 11):** The employee workstation, acting as the victim host. Simulated attacks are executed on this machine using Atomic Red Team.

All machines reside on an isolated host-only network with no access to external systems. The objective is to demonstrate how a SOC detects adversary activity through a SIEM and to document the process in an incident report aligned with the NIST SP 800-61 framework, using MITRE ATT&CK for technique mapping and Sigma for portable detection rules.

### 1.2 Monitoring Stack
The monitoring solution is based on Wazuh version 4.14.6, deployed on the WAZUH server. It consists of three core components:

- **Wazuh Manager:** The analysis engine. It receives raw logs, evaluates them against detection rules, and decides whether an event is normal activity or a security alert.
- **Wazuh Indexer:** The storage and indexing layer. It stores every log and indexes it so it can be searched quickly.
- **Wazuh Dashboard:** The human-facing web interface. It presents events clearly and allows the analyst to search, trace, and investigate activity.

Logs are forwarded from the endpoints using a **Wazuh agent** installed on each Windows machine. Each agent sends its logs to the Wazuh Manager over port **1514**.

The lab uses two network adapters per machine: one providing general internet access and a second host-only adapter connecting the machines to each other. Once setup is complete, the internet-facing adapter is disabled, leaving the machines connected but fully isolated through the host-only network.

### 1.3 Logging and Audit Policy
Scheduled task creation (T1053.005) was executed on WKSTN01 but produced no alert. The local Windows log showed the event was never recorded, because the relevant audit subcategory under Object Access is disabled by default.

Enabling it via `auditpol` caused Windows to log Event ID 4698, which was then forwarded and detected by Wazuh.

Key principle: a SIEM can only detect what the operating system actually logs. Detection begins with audit policy at the log source, not with the SIEM.

## 2. Detection and Analysis
### 2.1 Simulated Techniques
Two techniques were simulated on the victim host WKSTN01 using Atomic Red Team.

1. **Create Local Account (T1136.001):** Adversaries create a local account to maintain access to victim systems. Local accounts are configured by an organization for use by users, remote support, services, or administration on a single system.
   *Executed:* A local user named `atk_user` was created via PowerShell.

2. **Create Scheduled Task (T1053.005):** Adversaries may abuse the Windows Task Scheduler to perform task scheduling for initial or recurring execution of malicious code.
   *Executed:* A scheduled task was created to run on system startup and logon.

### 2.2 Detection Results
1. **Create Local Account (T1136.001):** Detected in Wazuh Threat Hunting on WKSTN01 (Jul 24, 2026). A single account creation generated multiple alerts: rule `60109` (account enabled/created) and rule `60110` (account changed), both at level 8, corresponding to Windows Event ID 4720.

2. **Create Scheduled Task (T1053.005):** Detected on WKSTN01 (Jul 25, 2026), rule `60228` at level 4, corresponding to Windows Event ID 4698.

3. **Audit Policy Change (side effect):** Enabling the audit policy was itself detected by rule `60112` at level 8 ("Windows Audit Policy changed"). This is significant because adversaries often modify audit settings to blind monitoring, making the detection of such changes a high-value alert.

### 2.3 Detection Gaps Identified
1. **Missing audit policy at the log source:** Scheduled task creation (T1053.005) initially produced no alert because Windows was not logging the event by default (see section 1.3). This confirmed that detection depends on correct audit configuration before any SIEM rule applies.

2. **Untested technique — service creation:** Windows service creation (T1543.003) could not be executed in the isolated environment. One test targeted a service that does not exist on the host, and another required an external binary blocked by the isolation. This technique therefore remains outside current detection coverage.

3. **Domain Controller not tested:** All simulated attacks targeted the workstation WKSTN01 only. The Domain Controller (DC01), the highest-value target in any network, was never attacked, so detection coverage for domain-level activity is currently unverified.

## 3. Containment, Eradication, and Recovery
As this was a controlled simulation in an isolated lab, full incident containment was not required. However, the equivalent controls were applied:

- **Containment:** The lab is isolated by design on a host-only network with no external access, mirroring the real-world first step of isolating a compromised host from the network.

- **Eradication:** After each simulation, the artifacts created by the attack (such as the `atk_user` account and the scheduled task) were removed using Atomic Red Team's `-Cleanup` function.

- **Recovery:** A VirtualBox snapshot taken before the attacks provided a clean rollback point, allowing each machine to be restored to a known-good state.

## 4. Post-Incident Activity
### 4.1 Lessons Learned
1. **Lab setup and administration:** Gained hands-on experience deploying and configuring virtual machines in VirtualBox, and working with Windows command-line tools in both PowerShell and CMD.
2. **Detection starts at the log source:** The most important lesson was that a SIEM can only detect what the operating system records. If an event is not logged, no SIEM will ever see the attack, regardless of which host it targets.
3. **Alert noise is a real challenge:** A monitored endpoint generates a large volume of alerts. A key future skill is filtering out low-value noise — and being aware that an attacker may deliberately disguise malicious activity to resemble benign, unfiltered alerts (a technique that exploits "alert fatigue").
4. **Methodology skills:** Learned to research techniques on MITRE ATT&CK, simulate them with Atomic Red Team, write portable detection rules in Sigma, and document the process using the NIST SP 800-61 framework.
5. **The analyst mindset:** Detection is not only about catching what fires an alert; it also means actively hunting for activity the system failed to detect, and investigating thoroughly.

### 4.2 Recommendations
1. **Test the Domain Controller:** Simulate attacks against DC01, the highest-value target in the network, and verify detection coverage for domain-level activity.
2. **Complete untested techniques:** Execute the service creation technique (T1543.003) in an environment that allows its prerequisites to be met.
3. **Develop custom detection rules:** Write dedicated Wazuh and Sigma rules for the gaps where built-in rules provided no coverage.
4. **Improve alert triage:** Build a process to filter low-value alerts and reduce noise, so genuine threats are not buried.