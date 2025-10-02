<#
TLS_Fixes_Only.ps1
Purpose: Minimal changes to remediate TLS 1.0 (104743) and TLS 1.1 (157288),
and ensure TLS 1.2 stays enabled. Nothing else added.
Run as Administrator. Reboot after.
#>

# --- Admin check ---
function Check-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Check-Admin)) {
    Write-Error "Access Denied. Please run with Administrator privileges."
    exit 1
}

$makeSecure = $true
$protoBase = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

function Ensure-Key { param([string]$Path) if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null } }

# --- TLS 1.0 ---
$serverPathTLS10 = Join-Path $protoBase "TLS 1.0\Server"
$clientPathTLS10 = Join-Path $protoBase "TLS 1.0\Client"
Ensure-Key $serverPathTLS10; Ensure-Key $clientPathTLS10

if ($makeSecure) {
    New-ItemProperty -Path $serverPathTLS10 -Name 'Enabled' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $serverPathTLS10 -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS10 -Name 'Enabled' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS10 -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "TLS 1.0 disabled."
} else {
    New-ItemProperty -Path $serverPathTLS10 -Name 'Enabled' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $serverPathTLS10 -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS10 -Name 'Enabled' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS10 -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "TLS 1.0 enabled."
}

# --- TLS 1.1 ---
$serverPathTLS11 = Join-Path $protoBase "TLS 1.1\Server"
$clientPathTLS11 = Join-Path $protoBase "TLS 1.1\Client"
Ensure-Key $serverPathTLS11; Ensure-Key $clientPathTLS11

if ($makeSecure) {
    New-ItemProperty -Path $serverPathTLS11 -Name 'Enabled' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $serverPathTLS11 -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS11 -Name 'Enabled' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS11 -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "TLS 1.1 disabled."
} else {
    New-ItemProperty -Path $serverPathTLS11 -Name 'Enabled' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $serverPathTLS11 -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS11 -Name 'Enabled' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS11 -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "TLS 1.1 enabled."
}

# --- TLS 1.2 (ensure enabled) ---
$serverPathTLS12 = Join-Path $protoBase "TLS 1.2\Server"
$clientPathTLS12 = Join-Path $protoBase "TLS 1.2\Client"
Ensure-Key $serverPathTLS12; Ensure-Key $clientPathTLS12

if ($makeSecure) {
    New-ItemProperty -Path $serverPathTLS12 -Name 'Enabled' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $serverPathTLS12 -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS12 -Name 'Enabled' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS12 -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "TLS 1.2 enabled."
} else {
    New-ItemProperty -Path $serverPathTLS12 -Name 'Enabled' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $serverPathTLS12 -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS12 -Name 'Enabled' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientPathTLS12 -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "TLS 1.2 disabled."
}

Write-Host "Please reboot for settings to take effect."
