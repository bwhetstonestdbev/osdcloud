$stampDate = Get-Date
$scriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $script:MyInvocation.MyCommand.Path -Leaf)))
$logFile = "$env:OSDCloud\Logs\$scriptName-" + $stampDate.ToFileTimeUtc() + ".log"
Start-Transcript -Path $logFile -NoClobber
$VerbosePreference = "Continue"

$input = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\Name.txt
Write-Host -ForegroundColor Red "Rename Computer before Domain Join"
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$ComputerName = $Serial + '-' + $input

$pass = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\pass.txt 
$SecurePassword = ConvertTo-SecureString $pass -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PSCredential ("stdbev.com\intune.dem",$SecurePassword)
Add-Computer -DomainName stdbev.com -Credential $Creds -OUPath "OU=Computers - STDBEV,DC=stdbev,DC=com" -NewName $ComputerName -Force -Restart

Stop-Transcript






