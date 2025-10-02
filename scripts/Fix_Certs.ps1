<#
Fix_Certs.ps1
Purpose:
- Remediates Nessus Plugin IDs 51192 and 57582 (untrusted/self-signed certs)
- Creates a Lab Root CA and signs a host cert
- Binds the cert to RDP (and optionally WinRM)
- Exports the Root CA for import into Nessus Trusted CAs

Run as Administrator. Reboot after.
#>

New-Item -Path C:\temp -ItemType Directory -Force | Out-Null

Write-Host "[1/5] Creating lab Root CA..."
$ts = (Get-Date -Format "yyyyMMddHHmmss")
$rootName = "LabRootCA-$ts"
$rootCert = New-SelfSignedCertificate -Type Custom -KeyExportPolicy Exportable -KeyLength 4096 `
  -KeyUsage CertSign,CRLSign -KeyAlgorithm RSA `
  -Subject "CN=$rootName" -CertStoreLocation "Cert:\LocalMachine\My" `
  -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(5)

# Trust it locally
$rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
$rootStore.Open("ReadWrite")
$rootStore.Add($rootCert)
$rootStore.Close()

Write-Host "[2/5] Issuing server auth cert signed by lab Root CA..."
$cn = "$env:COMPUTERNAME.lab.local"
$srvCert = New-SelfSignedCertificate -Type Custom -KeyExportPolicy Exportable -KeyLength 2048 `
  -KeyAlgorithm RSA -Subject "CN=$cn" -DnsName $cn,$env:COMPUTERNAME `
  -Signer $rootCert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1") `
  -CertStoreLocation "Cert:\LocalMachine\My" -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(2)

Write-Host "[3/5] Binding cert to RDP..."
$thumb = ($srvCert.Thumbprint).ToUpper()
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
                 -Name "SSLCertificateSHA1Hash" -Value $thumb

Write-Host "[4/5] (Optional) Bind cert to WinRM HTTPS listener..."
try {
  winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$env:COMPUTERNAME`"; CertificateThumbprint=`"$thumb`"}" | Out-Null
} catch {
  winrm set winrm/config/Listener?Address=*+Transport=HTTPS "@{CertificateThumbprint=`"$thumb`"}" | Out-Null
}

Write
