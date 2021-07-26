$sunpoolApiResponse = Invoke-RestMethod 'https://beam.sunpool.top/pool-info.php?miningpoolstats'
$sunpoolApi6hr_Hashrate = Invoke-RestMethod 'https://beam.sunpool.top/pool-info.php?pool-hash-rate-6h-avg'
$coinGeckoApiResponse = Invoke-RestMethod 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=btc&ids=beam'
$sunpoolMinerStatus = Invoke-RestMethod 'https://beam.sunpool.top/api.php?query=miner-workers&miner={minerAddy}'
$workerStatusValues = $sunpoolMinerStatus.data

$poolBlocks_24hr = $sunpoolApiResponse.blocksFound24H
$cg_BeamBtc = $coinGeckoApiResponse.current_price
$minerHashrate_6hr =  ($workerStatusValues.'6hAvgHashrate' | Measure-Object -Sum).Sum # 45.1 # Sol/s
$beamEmission = 40

$minerHashKSol = $minerHashrate_6hr / 1000
$poolBeamFound_24hr = $poolBlocks_24hr * $beamEmission
$poolKSol = $sunpoolApi6hr_Hashrate / 1000

$minerEstimate = $minerHashKSol * $poolBeamFound_24hr / $poolKSol

$mBTC_24hr = $minerEstimate * $cg_BeamBtc * 1000

Write-Host -ForegroundColor DarkBlue "$( [math]::Round($minerEstimate, 2))  Beam/day"
Write-Host -ForegroundColor DarkYellow "$( [math]::Round($mBTC_24hr, 3)) mBTC/day"