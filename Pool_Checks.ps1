Write-Host -ForegroundColor DarkGreen "Zergpool >>"
.\Check_Zergpool_Estimates.ps1 | select -First 10 | ft -AutoSize;
Write-Host -ForegroundColor DarkRed "Zpool >>"
.\Check_Zpool_Estimates.ps1 | select -First 10 | ft -AutoSize