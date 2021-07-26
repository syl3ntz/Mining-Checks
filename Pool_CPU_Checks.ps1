Write-Host -ForegroundColor DarkGreen "Zergpool >>"
.\Check_CPU_Zergpool_Estimates.ps1 | select -First 10 | ft -AutoSize;
Write-Host -ForegroundColor DarkRed "Zpool >>"
.\Check_CPU_Zpool_Estimates.ps1 | select -First 10 | ft -AutoSize