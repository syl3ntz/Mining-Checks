. .\Includes\Include.ps1
$Variables = @{}

$zPoolStatus = Invoke-RestMethod https://www.zpool.ca/api/status #-UseBasicParsing -Headers @{"Cache-Control" = "no-cache"} | ConvertFrom-Json
$zPoolValues = $zPoolStatus.psobject.properties.value
$zPoolCurrencies = Invoke-RestMethod https://www.zpool.ca/api/currencies #-UseBasicParsing -Headers @{"Cache-Control" = "no-cache"} | ConvertFrom-Json
$zPoolCurrenciesValues = $zPoolCurrencies.psobject.properties.Value

$divisorMulti = 1000000

$statusObjArray  = @()
$statsPath = ".\Stats"

$zPoolValues | ForEach-Object {
    $AlgoNorm = Get-Algorithm($_.Name)
    $divisor  = $divisorMulti * [double]$_.mbtc_mh_factor
    $estimatePerDivisor = $_.estimate_current / $divisor
    $statsFile = "$($AlgoNorm)_Hashrate.txt"
    $perCurrencyValues = $zPoolCurrenciesValues | Where-Object -Property Algo -EQ $_.Name | Select-Object -Property name,hashrate,estimate | Sort-Object -Descending -Property estimate #,network_Hashrate; does not exist on zpool
    
    $benchmarkUnsort = @()
    $sortedEstimates = @()
    #$LargestNetHash = @()

    $benchmarks = Get-ChildItem $statsPath | Where-Object {$_.Name -match $($statsFile) }
    $benchmarks | ForEach-Object {
        $dailyHash = $_ | Get-Content | ConvertFrom-Json | Select-Object -Property 'Day'

        $benchmarkUnsort += $dailyHash.Day        
    }
    $topHashRate = $benchmarkUnsort | Sort-Object -Descending | Select-Object -First 1

    $perCurrencyValues | ForEach-Object {
        $sortedEstimates += New-Object -TypeName psobject -Property @{ "Coin"=$_.name; "PoolHash"= $_.Hashrate } #$($_.Hashrate + $_.network_Hashrate) } no netHash on zpool

    }
    #$LargestNetHash += $topEstimate | Sort-Object -Descending -Property "PoolHash" | Select-Object -First 1 | Select-Object Coin,PoolHash
    $topEstimate = $sortedEstimates | Select-Object -First 1

    $statusObj = New-Object -TypeName psobject -Property @{Algorithm=$_.Name}
    $statusObj | Add-Member -MemberType NoteProperty -Name "mBTC Est" -Value $($estimatePerDivisor * $topHashrate * 1000).tostring("#.######")
    $statusObj | Add-Member -MemberType NoteProperty -Name "Workers" -Value $_.Workers
    $statusObj | Add-Member -MemberType NoteProperty -Name "Coin Stats" -Value $topEstimate
    if ($topEstimate.PoolHash -eq 0) {
        $statusObj | Add-Member -MemberType NoteProperty -Name "Party:Pool %" -Value $(1).tostring("##.##%")
    } else {
        $statusObj | Add-Member -MemberType NoteProperty -Name "Party:Pool %" -Value $($topHashrate * 10 / $topEstimate.'PoolHash').tostring("##.##%")
    }
    
    $statusObjArray += $statusObj
}

$statusObjArray | Sort-object -Descending -Property "mBTC Est" 