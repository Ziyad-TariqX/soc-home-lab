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

### 1.3 Logging and Audit Policy
Scheduled task creation (T1053.005) was executed on WKSTN01 but produced no alert. The local Windows log showed the event was never recorded, because the relevant audit subcategory under Object Access is disabled by default.

Enabling it via `auditpol` caused Windows to log Event ID 4698, which was then forwarded and detected by Wazuh.

Key principle: a SIEM can only detect what the operating system actually logs. Detection begins with audit policy at the log source, not with the SIEM.

## 2. Detection and Analysis
### 2.1 Simulated Techniques
### 2.2 Detection Results
### 2.3 Detection Gaps Identified

## 3. Containment, Eradication, and Recovery

## 4. Post-Incident Activity
### 4.1 Lessons Learned
### 4.2 Recommendations