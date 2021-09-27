
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

$Wallet = $null;
$walletExists = Test-Path -Path "$dir\wallet.txt" -PathType leaf
if ($walletExists -eq $false) {
    $Wallet = Read-Host -Prompt 'Input your Monero payout Wallet (Primary Address only!)'
    $Wallet = $Wallet.Trim()
    Write-Host "Saving wallet address on "$($dir)\wallet.txt": $($Wallet)"
    $Wallet | Out-File "$($dir)\wallet.txt"
} else {
    $Wallet = Get-Content "$dir\wallet.txt" -Raw
    Write-Host "Using stored wallet address on "$($dir)\wallet.txt": $($Wallet)"
}

Start-Process -ArgumentList "--data-dir=.", "--log-file", "$dir\bitmonero.log", "--enable-dns-blocklist", "--zmq-pub=tcp://127.0.0.1:18083", "--rpc-bind-ip=127.0.0.1", "--rpc-bind-port=18081", "--restricted-rpc", "--enforce-dns-checkpointing", "--fast-block-sync=1", "--sync-pruned-blocks", "--prune-blockchain", "--check-updates disabled", "--in-peers=8", "--out-peers=16", "--add-priority-node", "node.supportxmr.com:18080" .\monerod.exe

Write-Output "Waiting for monerod to start and sync..."

Start-Sleep -Seconds 15

Do {
    Try{
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:18081/json_rpc" -Method POST -Body '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -ContentType 'application/json'
        if ($response.result.synchronized -eq $false) {
            $percent = ($response.result.height/$response.result.target_height*100)
            Write-Progress -Activity "Waiting for monerod sync" -Status "$percent% Complete:" -PercentComplete $percent
            Start-Sleep -Seconds 5
        }
    } Catch {
        Start-Sleep -Seconds 15
    }

}While ($response.result.synchronized -ne $true)

Write-Progress -Activity "Waiting for monerod sync" -Completed

Write-Host "Starting p2pool with wallet $Wallet"

Start-Process -PassThru -ArgumentList "--wallet", "$Wallet" .\p2pool.exe

