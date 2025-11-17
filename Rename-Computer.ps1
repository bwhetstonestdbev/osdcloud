# Transcript for logging
$stampDate = Get-Date
$scriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $script:MyInvocation.MyCommand.Path -Leaf)))
$logFile = "$env:OSDCloud\Logs\$scriptName-" + $stampDate.ToFileTimeUtc() + ".log"
Start-Transcript -Path $logFile -NoClobber
$VerbosePreference = "Continue"

# Set Hostname before Autopilot
$input = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\Name.txt
Write-Host -ForegroundColor Red "Rename Computer before Domain Join"
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$ComputerName = 'D' + $Serial + '-' + $input
Rename-Computer -Newname $ComputerName -Force

Stop-Transcript




