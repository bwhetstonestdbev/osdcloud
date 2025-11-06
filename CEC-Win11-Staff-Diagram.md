```mermaid
flowchart TD
    A([Start Script])
    B{Is Computer Model Virtual?}
    C[Set Display Resolution to 1600x]
    D[Update OSD PowerShell Module]
    E[Import OSD PowerShell Module]
    F{Prompt for Asset Tag 4-5 digits}
    G[Save Asset Tag to file]
    H[Show valid asset tag message]
    I[Set OSDCloud Params]
    J[Start-OSDCloud]
    K[Create OOBEDeploy json]
    L[Create AutopilotOOBE json]
    M[Download Setup Scripts AssetTag, Rename, Autopilot, Bios]
    N[Create oobe.cmd]
    O[Create SetupComplete.cmd]
    P[Create Unattend.xml]
    Q[Ensure Panther Directory]
    R[Copy USB Scripts to C:\OSDCloud]
    S[Restart in 20 seconds]
    T[wpeutil reboot]

    A --> B
    B -- Yes --> C
    B -- No --> D
    C --> D
    D --> E
    E --> F
    F -- Valid --> G
    G --> H
    H --> I
    I --> J
    J --> K
    K --> L
    L --> M
    M --> N
    N --> O
    O --> P
    P --> Q
    Q --> R
    R --> S
    S --> T
```