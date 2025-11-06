# OSDCloud Deployment Scripts

TPowerShell scripts and resources for deploying Windows 11 images using OSDCloud, including automation for lab, A3 licensed staff, and A1 licensed staff.

## Contents

- **1)Win11-Lab.ps1**: Deploys Windows 11 for lab environments (automated).
    - Deployment mode: Self-Deploying
    - Device Group `Computer Config - BASE Win11 Labs`
- **2)Win11-Lab_MANUAL_PROCCESS.ps1**: Deploys Windows 11 for lab environments (manual process).
    - Deployment mode: Self-Deploying
    - Device Group `Computer Config - BASE Win11 Labs`
- **3)Win11-Staff_FT.ps1**: Deploys Windows 11 for full-time staff devices.
    - Deployment mode: User-Driven
    - Device Group `Autopilot - Device - Staff Win11`
- **4)Win11-Staff_PT.ps1**: Deploys Windows 11 for part-time/contractor/shared staff devices.
    - Deployment mode: Self-Deploying
    - Device Group `Autopilot - Device - Staff Shared Win11`
- **Test-DoNotUse.ps1**: Test script for deployment and configuration.

## Log File Locations

| Script Name                | Log File Location                                                                                     | 
|----------------------------|-------------------------------------------------------------------------------------------------------|
| `Autopilot.ps1`            | `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\*-Autopilot-Tasks.log`                   | 
| `Lab_Rename-Computer.ps1`  | `C:\Logs\Lab_Rename-Computer-[DateTime].log`                                                              |       
| `Rename-Computer.ps1`  | `C:\Logs\Lab_Rename-Computer-[DateTime].log`                                                              |  
| `Set-LenovoAssetTag.ps1` | `C:\Logs\Set-LenovoAssetTag-[DateTime].log` |
|`Set-LenovoBios.ps1` | `C:\OSDCloud\Logs\[DateTime]-Set_Lenovo_BIOS_Settings.log`  |

## Related Documentation

- [CEC-Win11-Lab-Diagram](./CEC-Win11-Lab-Diagram.md)
- [CEC-Win11-Staff-Diagram](./CEC-Win11-Staff-Diagram.md)

