# Transcript for logging
$stampDate = Get-Date
$scriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $script:MyInvocation.MyCommand.Path -Leaf)))
$logFile = "$env:OSDCloud\Logs\$scriptName-" + $stampDate.ToFileTimeUtc() + ".log"
Start-Transcript -Path $logFile -NoClobber
$VerbosePreference = "Continue"

# Set Hostname before Autopilot
param(
$Name
)
Write-Host -ForegroundColor Red "Rename Computer before Domain Join"
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$ComputerName = 'D' + $Serial + '-' + $Name
Rename-Computer -Newname $ComputerName -Restart -Force

Stop-Transcript

