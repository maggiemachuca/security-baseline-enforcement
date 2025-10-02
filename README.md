
# 🔐 Windows 10 Compliance Hardening (NIST 800-53 Aligned)

> A hands-on lab where I hardened a misconfigured Windows 10 Pro VM, scanned it using Nessus Essentials from an Ubuntu 22.04 VM, and remediated several medium/high vulnerabilities using PowerShell and registry edits. The project reflects real-world RMF Step 4 (control assessment) and NIST 800-53-aligned hardening techniques.

---

## 📌 Overview

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

Disabled 3DES/RC4 (SWEET32) shown in Nessus scan:




---

## 📄 Scripts Used

| Script Name             | Purpose                               |
|-------------------------|----------------------------------------|
| `disable-tls.ps1`       | Disable TLS 1.0/1.1, enable TLS 1.2   |
| `Fix_SWEET32_SMB.ps1`   | Disable weak ciphers, enforce SMB signing |
| `Fix_Certs.ps1`         | Create and bind lab CA + RDP cert (optional) |

📸 **Screenshot Suggestion:** `screenshots/script-running.png`

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

<img width="1010" height="353" alt="Screenshot 2025-10-01 at 10 51 25 PM" src="https://github.com/user-attachments/assets/a6f0d9d0-b059-433b-a447-e42a6025d810" />

---

## 📝 Notes on Certificate Findings

> I created a lab Root Certificate Authority (CA) and used it to issue a server authentication cert for RDP. While the cert was successfully bound, I chose **not to import the CA into Nessus Trusted CAs** to reflect realistic internal lab limitations.

📸 **Screenshots:** 
<img width="294" height="28" alt="Screenshot 2025-10-01 at 10 52 31 PM" src="https://github.com/user-attachments/assets/995acd9c-fcec-480f-a228-9082b7502b7f" />


---

## 💡 Skills Demonstrated

- Windows system hardening
- Nessus scan analysis & plugin interpretation
- Registry editing with PowerShell
- Cipher suite and TLS protocol management
- Certificate creation & binding (RDP)
- Security documentation and evidence tracking
- RMF Step 4: Assessing controls
- NIST 800-53 control alignment (e.g., SC-12, SC-28, AC-17)

---

## 📁 Repo Structure

```
📁 screenshots/
  ├─ initial-nessus-scan.png
  ├─ tls-registry-settings.png
  ├─ smb-signing-registry.png
  ├─ final-scan.png
  ├─ lab-root-ca-export.png

📄 Fix_TLS.ps1
📄 Fix_SWEET32_SMB.ps1
📄 Fix_Certs.ps1
📄 README.md
```

---

## 📆 Project Date

- **Completed:** 2025-10-02

---

## ✅ Next Steps

- Import CA into Nessus to clear cert warnings
- Expand to include PolicyAnalyzer vs Microsoft Baselines
- Automate scan → fix → re-scan workflows
