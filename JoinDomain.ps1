$stampDate = Get-Date
$scriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $script:MyInvocation.MyCommand.Path -Leaf)))
$logFile = "$env:OSDCloud\Logs\$scriptName-" + $stampDate.ToFileTimeUtc() + ".log"
Start-Transcript -Path $logFile -NoClobber
$VerbosePreference = "Continue"
 
$SecurePassword = ConvertTo-SecureString "!Ntun3dem" -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PSCredential ("stdbev.com\intune.dem",$SecurePassword)
Add-Computer -DomainName stdbev.com -Credential $Creds -OUPath "OU=Computers - STDBEV,DC=stdbev,DC=com" -Restart

Stop-Transcript


