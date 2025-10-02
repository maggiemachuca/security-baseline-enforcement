
# 🔐 Windows 10 Compliance Hardening (NIST 800-53 Aligned)

> A hands-on lab where I hardened a misconfigured Windows 10 Pro VM, scanned it using Nessus Essentials from an Ubuntu 22.04 VM, and remediated several medium/high vulnerabilities using PowerShell and registry edits. This project is an implementation of RMF Step 4: Assess Security Controls, using system hardening techniques aligned with NIST 800-53 standards.
---

## Technical Skills

- Windows system hardening
- Nessus scan analysis & plugin interpretation
- Registry editing with PowerShell
- Cipher suite and TLS protocol management
- Certificate creation & binding (RDP)
- Security documentation and evidence tracking
- RMF Step 4: Assessing controls
- NIST 800-53 control alignment (e.g., SC-12, SC-28, AC-17)

---

## 📌 High-Level Overview

This project demonstrates my ability to:

- Deploy and assess a **Windows 10 Pro** virtual machine
- Run vulnerability scans with **Nessus Essentials** from an **Ubuntu 22.04** scanner VM
- Remediate misconfigurations using **PowerShell**, **registry changes**, and **best practices**
- Align technical hardening to **NIST 800-53** control families (e.g., SC, AC, AU)
- Simulate RMF Step 4: **Assess Security Controls**

---

## ☁️ Lab Environment

| Component         | Details                      |
|------------------|------------------------------|
| Hypervisor       | Azure (Student Subscription) |
| Target VM        | Windows 10 Pro               |
| Scanner VM       | Ubuntu 22.04                 |
| Scanner Tool     | Nessus Essentials            |
| Remediation Tool | PowerShell (Admin)           |
| Network Config   | Shared virtual network (VNet) with private IPs |

## Preparation:

Before scanning or remediating the system, I performed the following steps to prepare the lab environment:

- Deployed two Azure VMs:  
  - **Windows 10 Pro** (system with intentional misconfigurations)  
  - **Ubuntu 22.04** (scanner machine running Nessus Essentials)

- Created a **shared virtual network** so the scanner could reach the target via private IP

- Installed **Nessus Essentials** on Ubuntu using the correct `.deb` package 

---
## Scenario:

During an internal security audit, a Windows 10 Pro workstation image was found being used across several internal machines. This image had originally been deployed by IT for temporary contractor workstations but had never gone through formal security hardening or baseline validation.

I was tasked with scanning the system, identifying compliance gaps, and remediating misconfigurations based on best practices aligned to NIST 800-53 and the RMF control assessment step (Step 4).

The goal was to bring the system into compliance with internal hardening standards, while also documenting the before/after states for audit reporting and future automation planning.

---

## 🚨 Initial Vulnerability Scan (Before Hardening)

Using Nessus Essentials, I scanned the misconfigured Windows 10 VM and discovered the following:

| Plugin ID | Name                                      | Severity |
|-----------|-------------------------------------------|----------|
| 42873     | SSL Medium Strength Cipher Suites (3DES)  | High     |
| 104743    | TLS Version 1.0 Protocol Detected         | Medium   |
| 157288    | TLS Version 1.1 Protocol Detected         | Medium   |
| 57608     | SMB Signing Not Required                  | Medium   |
| 51192     | SSL Certificate Cannot Be Trusted         | Medium   |
| 57582     | SSL Self-Signed Certificate               | Medium   |

Initial Scan Results: 

<img width="1017" height="609" alt="Screenshot 2025-10-01 at 10 36 33 PM" src="https://github.com/user-attachments/assets/2453e3a0-cab8-412a-a21d-9f8248f50f53" />

---

## 🔧 Remediation Actions

All remediations were applied manually using **PowerShell (Admin)** sessions and custom scripts.

| Plugin(s) Fixed     | Fix Description                          | Method        |
|---------------------|-------------------------------------------|---------------|
| 104743, 157288      | Disabled TLS 1.0 and 1.1                  | PowerShell     |
| 42873               | Disabled 3DES/RC4 (SWEET32)               | PowerShell     |
| 57608               | Enforced SMB signing                      | PowerShell     |




📸 **Screenshots**
Disabling TLS 1.0 and 1.1 while enabling 1.2:
<img width="785" height="109" alt="Screenshot 2025-10-01 at 9 16 52 PM" src="https://github.com/user-attachments/assets/55ded659-6442-4d39-958f-924e3ee3b4f6" />

Scan results after disabling TLS 1.0/1.1 and enabling 1.2:
<img width="1006" height="430" alt="Screenshot 2025-10-01 at 11 08 47 PM" src="https://github.com/user-attachments/assets/c4758838-2d2b-4fd3-a095-d665f25dce4b" />



Scan results after remediating SWEET32 and SMB signing misconfiguration vulnerabilities: 
<img width="1015" height="358" alt="Screenshot 2025-10-01 at 11 04 00 PM" src="https://github.com/user-attachments/assets/8ed8b99f-9b07-4e9e-9ab0-507d76bc777a" />



---

## 📄 Scripts Used

| Script Name             | Purpose                               |
|-------------------------|----------------------------------------|
| `disable-tls.ps1`       | Disable TLS 1.0/1.1, enable TLS 1.2   |
| `Fix_SWEET32_SMB.ps1`   | Disable weak ciphers, enforce SMB signing |
| `Fix_Certs.ps1`         | Create and bind lab CA + RDP cert (optional) |

---

## Note on PowerShell Scripts

During the hardening process, I created several PowerShell scripts to apply security settings such as disabling insecure protocols, enforcing SMB signing, and modifying registry keys.

Since these scripts were saved directly to the VM (either from the browser or through file transfer), Windows automatically flagged them as potentially unsafe — a built-in security feature known as the Zone Identifier or "Mark of the Web."

As a result, PowerShell blocked the scripts from running by default, even when I had administrative privileges.

To fix this, I had to manually unblock each script. This is a common step in environments where scripts are shared or downloaded. I used this PowerShell script to allow the scripts to run (of course changing the file name appropriately):

```
Unblock-File -Path "C:\Users\mmach\Desktop\Fix_TLS.ps1"
```
---

## ✅ Final Scan Results (After Hardening)

After applying the remediations, I performed a new Nessus scan. These findings were resolved:

| Plugin ID | Status      |
|-----------|-------------|
| 42873     | ✅ Fixed     |
| 104743    | ✅ Fixed     |
| 157288    | ✅ Fixed     |
| 57608     | ✅ Fixed     |

📸 **Screenshots** 
Final Scan result:

<img width="1015" height="358" alt="Screenshot 2025-10-01 at 11 04 00 PM" src="https://github.com/user-attachments/assets/8ed8b99f-9b07-4e9e-9ab0-507d76bc777a" />

---

## NIST 800-53 Control Mapping

| **Remediation**                                               | **Plugin(s) Addressed**   | **Mapped Control(s)**                 | **Why It Matters**                                                                               |
| ------------------------------------------------------------- | ------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------ |
| **Disabled TLS 1.0 / 1.1**                                    | 104743, 157288            | `SC-12`, `SC-13`, `SC-28`             | Makes sure only modern, secure encryption is used when data is sent across the network           |
| **Disabled weak ciphers (3DES/RC4)**                          | 42873                     | `SC-12`, `SC-13`, `SC-28`, `SC-28(1)` | Prevents attackers from taking advantage of outdated encryption methods                          |
| **Enforced SMB Signing**                                      | 57608                     | `SC-7(11)`, `SC-23`, `AC-17(2)`       | Ensures file sharing traffic can't be tampered with or impersonated                              |
| **Handled script blocking** (unblocked safe scripts manually) | *(observed behavior)*     | `SI-7`, `AC-6`, `CM-6`                | Shows awareness of how Windows protects systems from potentially unsafe or untrusted scripts     |

### 🧠 Reflection

This project simulates how real-world misconfigurations are identified and remediated. I not only learned how to interpret Nessus scan results, but also how to apply safe, targeted fixes using PowerShell in alignment with industry-standard frameworks like NIST 800-53 and the RMF process.

I also had to think critically about which vulnerabilities truly needed to be remediated (e.g., TLS, SMB signing, SWEET32), and which were acceptable to leave in place in an internal lab setting (e.g., certificate trust warnings). Overall, this project helped me connect technical security work with the broader goals of compliance, documentation, and system hardening.


