if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Green "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

# Prompt the user to enter the name of the co-worker the computer will be assigned to for the computer name
    
Write-Host -ForegroundColor Cyan "Enter name of co-worker using this computer:"
$user = Read-Host
$firstName, $lastName = $user -Split " "
$firstNameTrim = $firstName[0]
    if ($lastName.Length -ge 5){
        $lastNameTrim = $lastName.Substring(0,5)
    }

    else {$lastNameTrim = $lastName}
    $nameUpper = ("$firstNameTrim$lastNameTrim").ToUpper()
    $nameUpper | Out-File -FilePath "X:\OSDCloud\Config\Scripts\Name.txt" -Encoding ascii -Force
    
Write-Output "Co-worker name within computer name will be: $nameUpper"

Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion  = "Windows 11"
    OSBuild    = "25H2"
    OSEdition  = "Pro"
    OSLanguage = "en-us"
    OSLicense  = "Volume"
    ZTI        = $true
    Firmware   = $true
}
Start-OSDCloud @Params
