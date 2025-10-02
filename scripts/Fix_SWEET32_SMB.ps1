<#
Fix_SWEET32_SMB.ps1
Targets:
- 42873: Disable weak SCHANNEL ciphers (3DES/RC4); keep AES enabled
- 57608: Require SMB signing (server-side)
Safe for RDP/WinRM. Reboot recommended.
#>

function Ensure-Key { param([string]$Path) if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null } }

Write-Host "[1/3] Disable weak SCHANNEL ciphers (3DES/RC4) and ensure AES is enabled..."
$baseCiphers = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"
Ensure-Key $baseCiphers

# Disable RC4 & 3DES
$disable = @("RC4 128/128","RC4 64/128","RC4 56/128","RC4 40/128","Triple DES 168")
foreach ($c in $disable) {
  $p = Join-Path $baseCiphers $c
  Ensure-Key $p
  New-ItemProperty -Path $p -Name "Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
}

# Explicitly enable AES (usually default, but set to be sure)
$enable = @("AES 128/128","AES 256/256")
foreach ($c in $enable) {
  $p = Join-Path $baseCiphers $c
  Ensure-Key $p
  New-ItemProperty -Path $p -Name "Enabled" -Value 1 -PropertyType DWord -Force | Out-Null
}

Write-Host "[2/3] Enforce SMB signing (server-side) -> fixes 57608"
$lanman = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
Ensure-Key $lanman
New-ItemProperty -Path $lanman -Name "RequireSecuritySignature" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $lanman -Name "EnableSecuritySignature" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "[3/3] Nudge services; export policy snapshot"
Restart-Service -Name LanmanServer -ErrorAction SilentlyContinue
secedit /export /cfg C:\temp\local_policy_after_crypto_smb.inf | Out-Null

Write-Host "Done. Reboot recommended to fully apply SCHANNEL changes."
