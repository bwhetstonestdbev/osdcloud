$SecurePassword = ConvertTo-SecureString "!Ntun3dem" -AsPlainText -Force

$Creds = New-Object System.Management.Automation.PSCredential ("intune.dem",$SecurePassword)

Add-Computer -DomainName stdbev.com -Credential $Creds -OUPath "OU=Computers - STDBEV,DC=stdbev,DC=com" -Restart