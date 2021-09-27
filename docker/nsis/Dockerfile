FROM debian:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    curl unzip gnupg ca-certificates \
    nsis nsis-pluginapi && \
    rm -rf /var/lib/apt/lists/*

ARG P2POOL_GPGKEY_URL=https://raw.githubusercontent.com/monero-project/gitian.sigs/50672d1513f3aedc144a98b8b11224e9f6f75ef2/gitian-pubkeys/SChernykh.asc
ARG P2POOL_GPGKEY_FINGERPRINT=1FCAAB4D3DC3310D16CBD508C47F82B54DA87ADF

# Import and trust GPG key for signed releases
RUN set -eux; \
    curl "${P2POOL_GPGKEY_URL}" | gpg --import - && \
    gpg --fingerprint "0x${P2POOL_GPGKEY_FINGERPRINT}" && \
    echo "${P2POOL_GPGKEY_FINGERPRINT}:6:" | gpg --import-ownertrust

COPY entrypoint.sh /entrypoint.sh
COPY start.ps1 /start.ps1
COPY p2pool.nsi /p2pool.nsi

WORKDIR /tmp

ENTRYPOINT ["/entrypoint.sh"]