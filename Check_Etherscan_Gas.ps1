$gas_resp = irm -Method Get -Uri "https://api.etherscan.io/api?module=gastracker&action=gasoracle" -Headers @{"Cache-Control" = "no-cache"}

$gas_values = New-Object -TypeName psobject -Property @{"ProposedGas"=$gas_resp.result.ProposeGasPrice}
$gas_values | Add-Member -MemberType NoteProperty -Name "SafeGas" -Value $gas_resp.result.SafeGasPrice
$gas_values | Add-Member -MemberType NoteProperty -Name "FastGas" -Value $gas_resp.result.FastGasPrice

$gas_values

#$gas = 30 / [int]"1,000,000,000"
#$eth = $gas * ($std_xfer = 21000)
#$eth * 472.98 #USD value of ETH currently