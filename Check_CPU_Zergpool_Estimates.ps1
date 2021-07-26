. .\Includes\Include.ps1
$Variables = @{}

$zergPoolStatus = Invoke-WebRequest http://api.zergpool.com:8080/api/status -UseBasicParsing -Headers @{"Cache-Control" = "no-cache"} | ConvertFrom-Json
$zergPoolValues = $zergPoolStatus.psobject.Properties.value
$zergPoolCurrencies = Invoke-WebRequest http://api.zergpool.com:8080/api/currencies -UseBasicParsing -Headers @{"Cache-Control" = "no-cache"} | ConvertFrom-Json
$zergPoolCurrenciesValues = $zergPoolCurrencies.psobject.properties.Value

$divisorMulti = 1000000

$statusObjArray  = @()
$statsPath = ".\Stats"

$zergPoolValues | ForEach-Object {
    $AlgoNorm = Get-Algorithm($_.Name)
    $divisor  = $divisorMulti * [double]$_.mbtc_mh_factor
    $estimatePerDivisor = $_.estimate_current / $divisor
    $statsFile = "$($AlgoNorm)_hashrate.txt"
    $algoPoolNetHash = $zergPoolCurrenciesValues | Where-Object -Property Algo -Match $_.Name | Select-Object -Property name,hashrate,network_hashrate
    
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
        $netHashUnsort += New-Object -TypeName psobject -Property @{ "Coin"=$_.name; "NetHash"= $($_.hashrate + $_.network_hashrate) }

    }
    $LargestNetHash += $netHashUnsort | Sort-Object -Descending -Property "NetHash" | Select-Object -First 1 | Select-Object Coin,NetHash

    $statusObj = New-Object -TypeName psobject -Property @{Algorithm=$_.Name;"Est Per Div"=$estimatePerDivisor}
    $statusObj | Add-Member -MemberType NoteProperty -Name "mBTC Est" -Value $($estimatePerDivisor * $hashrate * 1000).tostring("#.######")
    $statusObj | Add-Member -MemberType NoteProperty -Name "Workers" -Value $_.Workers
    $statusObj | Add-Member -MemberType NoteProperty -Name "NetHash" -Value $LargestNetHash
    $statusObj | Add-Member -MemberType NoteProperty -Name "Party:TotalNet%" -Value $($hashrate * 10 / $LargestNetHash.'NetHash').tostring("##.##%")


    $statusObjArray += $statusObj
}

$statusObjArray | Sort-object -Descending -Property "mBTC Est" | Select-Object Algorithm,"mBTC Est",Workers,NetHash,"Party:TotalNet%"

#use an array to store coin net hashes