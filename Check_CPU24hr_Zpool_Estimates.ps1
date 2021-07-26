. .\Includes\Include.ps1
$Variables = @{}

$zergPoolStatus = Invoke-WebRequest http://www.zpool.ca/api/status -UseBasicParsing -Headers @{"Cache-Control" = "no-cache"} | ConvertFrom-Json
$zergPoolValues = $zergPoolStatus.psobject.Properties.value
$zergPoolCurrencies = Invoke-WebRequest http://www.zpool.ca/api/currencies -UseBasicParsing -Headers @{"Cache-Control" = "no-cache"} | ConvertFrom-Json
$zergPoolCurrenciesValues = $zergPoolCurrencies.psobject.properties.Value

$divisorMulti = 1000000

$statusObjArray  = @()
$statsPath = ".\Stats"

$zergPoolValues | ForEach-Object {
    $AlgoNorm = Get-Algorithm($_.Name)
    $divisor  = $divisorMulti * [double]$_.mbtc_mh_factor
    $estimatePerDivisor = $_.estimate_last24h / $divisor
    $statsFile = "$($AlgoNorm)_hashrate.txt"
    $algoPoolNetHash = $zergPoolCurrenciesValues | Where-Object -Property Algo -Match $_.Name | Select-Object -Property name,hashrate #,network_hashrate; does not exist on zpool
    
    $hashValueUnsort = @()
    $netHashUnsort = @()
    $LargestNetHash = @()

    $hashValues = Get-ChildItem $statsPath | Where-Object {$_.Name -like "CPU*$($statsFile)" }
    $hashValues | ForEach-Object {
        $rawHash = $_ | Get-Content | ConvertFrom-Json | Select-Object -Property 'Day'

        $hashvalueUnsort += $rawHash.Day        
    }
    $hashRate = $hashValueUnsort | Sort-Object -Descending | Select-Object -First 1

    $algoPoolNetHash | ForEach-Object {
        $netHashUnsort += New-Object -TypeName psobject -Property @{ "Coin"=$_.name; "PoolHash"= $_.hashrate } #$($_.hashrate + $_.network_hashrate) } no netHash on zpool

    }
    $LargestNetHash += $netHashUnsort | Sort-Object -Descending -Property "PoolHash" | Select-Object -First 1    

    $statusObj = New-Object -TypeName psobject -Property @{Algorithm=$_.Name;"Est Per Div"=$estimatePerDivisor}
    $statusObj | Add-Member -MemberType NoteProperty -Name "mBTC Est" -Value $($estimatePerDivisor * $hashrate * 1000).tostring("#.######")
    $statusObj | Add-Member -MemberType NoteProperty -Name "Workers" -Value $_.Workers
    $statusObj | Add-Member -MemberType NoteProperty -Name "Pool Hashrate" -Value $LargestNetHash
    if ($LargestNetHash.PoolHash -eq 0) {
        $statusObj | Add-Member -MemberType NoteProperty -Name "Party:Pool %" -Value $(1).tostring("##.##%")
    } else {
        $statusObj | Add-Member -MemberType NoteProperty -Name "Party:Pool %" -Value $($hashrate * 10 / $LargestNetHash.'PoolHash').tostring("##.##%")
    }
    


    $statusObjArray += $statusObj
}

$statusObjArray | Sort-object -Descending -Property "mBTC Est" | Select-Object Algorithm,"mBTC Est",Workers,"Pool Hashrate","Party:Pool %"