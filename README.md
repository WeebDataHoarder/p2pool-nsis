# No longer maintained. Use [Gupax]

This repository is no longer maintained, although it should keep working if you need new releases. 

Use [[Gupax]](https://github.com/hinto-janai/gupax) instead, a P2Pool+Monero+XMRig GUI.

# p2pool-nsis

Windows installer for [Monero's P2Pool](https://github.com/SChernykh/p2pool).

## Download
**[Get the last stable release here](https://github.com/WeebDataHoarder/p2pool-nsis/releases/latest)**

## Features
* Uses [P2Pool released binaries](https://github.com/SChernykh/p2pool/releases), with checked signatures
* Direct installation to user folder
* Automatically enable Huge Pages if installer is started as Administrator.
* Allows starting both _monerod_ and _p2pool_ from a single shortcut.
* No need to setup command line parameters.
* Remembers your wallet address for payouts.
* Supports Windows 7, 8, 8.1, 10+ 64-bit
* NSIS based!

## How to build binaries 
* You will need _git_, and _Docker_ setup and running.
* Clone the repository. Run `$ ./build.sh`.
* Output will be on _build/nsis_ directory.

## Deterministic builds
Builds are deterministic. Due to Debian package updates nsis / gcc builder might change, in such cases we might need to compile our own.

Logs and hashes for builds are [available here](https://github.com/WeebDataHoarder/p2pool-nsis/actions/workflows/build.yml). 
Please test any changes you make via `./test-deterministic-build.sh`, which builds twice in a row and compares hashes / hex diff.

## Mining / xmrig usage
Download xmrig from [https://xmrig.com/download](https://xmrig.com/download)

Attached is the _config.json_ file to use with xmrig.
Alternatively you can point xmrig to url `127.0.0.1:3333` to mine.
You can also specify user `x+600000` to get local hashrate reporting on p2pool

Remote mining is supported. Point to port `<your local ip>:3333`, might need to open ports externally.

## Contribution
Submit a pull request with any suggested changes. You can also come for help to `IRC #p2pool-log @ libera.chat`

There is no dev fee. p2pool has no infrastructure. Send donations if you like, or don't.

[![Donate Monero](https://img.shields.io/badge/Donate-Monero-green.svg)](monero:4AeEwC2Uik2Zv4uooAUWjQb2ZvcLDBmLXN4rzSn3wjBoY8EKfNkSUqeg5PxcnWTwB1b2V39PDwU9gaNE5SnxSQPYQyoQtr7)

Donate hashrate to the [P2Pool Seed Node we run](https://seed.p2pool.observer), at stratum server `seed.p2pool.observer:3333`

Think about donating to [p2pool's original author](https://github.com/SChernykh/p2pool#donations) as well. 
