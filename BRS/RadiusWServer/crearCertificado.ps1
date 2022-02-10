$date = (Get-Date).ToString('MMM-yyyy')
$certificateExpiringYears = (Get-Date).AddYears(2)
$FQND = "wificontroller.ciber.local"
$friendlyname = "wificontroller"
New-SelfSignedCertificate -DnsName $FQND -KeyLength 2048 -CertStoreLocation "Cert:LocalMachine\My" `
-FriendlyName $friendlyname -NotAfter $certificateExpiringYears
