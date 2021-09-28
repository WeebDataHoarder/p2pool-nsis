Clear-Host

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path "$scriptpath"
Push-Location $dir

Function ConvertFrom-Json-Compat {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [object]$item
    )
    PROCESS {
        add-type -assembly system.web.extensions
        $ps_js=new-object system.web.script.serialization.javascriptSerializer
        return $ps_js.DeserializeObject($item)
    }
}

Function Get-Monero-Status
{
    $webclient = New-Object System.Net.WebClient
    $webclient.Headers.add("ContentType", "application/json")
    $response = $webClient.UploadString("http://127.0.0.1:18081/json_rpc", "POST", '{"jsonrpc":"2.0","id":"0","method":"get_info"}')

    return $response | ConvertFrom-Json-Compat
}

$Wallet = "";
$walletExists = Test-Path -Path "$dir\wallet.txt" -PathType leaf
if ($walletExists) {
    $Wallet = [IO.File]::ReadAllText("$dir\wallet.txt")
    $Wallet = $Wallet.Trim()
    Write-Output "Using stored wallet address on `"$($dir)\wallet.txt`": $($Wallet)"
}

if ($Wallet -eq "") {
    $Wallet = Read-Host -Prompt 'Input your Monero payout Wallet (Primary Address only!)'
    $Wallet = $Wallet.Trim()
    Write-Output "Saving wallet address on `"$($dir)\wallet.txt`": $($Wallet)"
    $Wallet | Out-File -Encoding utf8 "$($dir)\wallet.txt"
}

Start-Process .\monerod.exe -ArgumentList "--data-dir=.","--log-file","$dir\bitmonero.log","--enable-dns-blocklist","--zmq-pub=tcp://127.0.0.1:18083","--rpc-bind-ip=127.0.0.1","--rpc-bind-port=18081","--restricted-rpc","--disable-dns-checkpoints","--fast-block-sync=1", "--sync-pruned-blocks","--prune-blockchain","--check-updates disabled","--in-peers=8","--out-peers=16","--add-priority-node","node.supportxmr.com:18080"

Write-Output "Waiting for monerod to start and sync..."

Do {
    Try{
        $response = Get-Monero-Status
        if (-Not $response.result.synchronized) {
            $percent = ($response.result.height/$response.result.target_height*100)
            Write-Progress -Activity "Waiting for monerod sync" -Status "$percent% Complete:" -PercentComplete $percent
            Start-Sleep -Seconds 5
        }
    } Catch {
        Start-Sleep -Seconds 5
    }

}While (-Not $response.result.synchronized)

Write-Progress -Activity "Waiting for monerod sync" -Completed

Write-Output "Starting p2pool with wallet $Wallet"

Start-Process .\p2pool.exe -ArgumentList "--wallet $Wallet" -NoNewWindow

