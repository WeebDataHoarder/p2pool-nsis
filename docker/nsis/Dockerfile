FROM debian:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    curl unzip gnupg ca-certificates \
    nsis nsis-pluginapi && \
    rm -rf /var/lib/apt/lists/*

ARG P2POOL_GPGKEY_URL=https://raw.githubusercontent.com/monero-project/gitian.sigs/50672d1513f3aedc144a98b8b11224e9f6f75ef2/gitian-pubkeys/SChernykh.asc
ARG P2POOL_GPGKEY_FINGERPRINT=1FCAAB4D3DC3310D16CBD508C47F82B54DA87ADF

ARG MONERO_GPGKEY_URL=https://raw.githubusercontent.com/monero-project/monero/aa9ba3064e4b59f7c378561f2716ca129bc7f846/utils/gpg_keys/binaryfate.asc
ARG MONERO_GPGKEY_FINGERPRINT=81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92


# Import and trust GPG key for signed releases
RUN set -eux; \
    curl "${P2POOL_GPGKEY_URL}" | gpg --import - && \
    gpg --fingerprint "0x${P2POOL_GPGKEY_FINGERPRINT}" && \
    echo "${P2POOL_GPGKEY_FINGERPRINT}:6:" | gpg --import-ownertrust

RUN set -eux; \
    curl "${MONERO_GPGKEY_URL}" | gpg --import - && \
    gpg --fingerprint "0x${MONERO_GPGKEY_FINGERPRINT}" && \
    echo "${MONERO_GPGKEY_FINGERPRINT}:6:" | gpg --import-ownertrust

#ARG XMRIG_GPGKEY_URL=https://raw.githubusercontent.com/xmrig/xmrig/997f90dae73f74171a6d25e6b83f287715c4b0d0/doc/gpg_keys/xmrig.asc
#ARG XMRIG_GPGKEY_FINGERPRINT=9AC4CEA8E66E35A5C7CDDC1B446A53638BE94409
#
#RUN set -eux; \
#    curl "${XMRIG_GPGKEY_URL}" | gpg --import - && \
#    gpg --fingerprint "0x${XMRIG_GPGKEY_FINGERPRINT}" && \
#    echo "${XMRIG_GPGKEY_FINGERPRINT}:6:" | gpg --import-ownertrust

ARG USER_MGR_PLUGIN_URL="https://nsis.sourceforge.io/mediawiki/images/4/4a/UserMgr_%282021%29.zip"
ARG USER_MGR_PLUGIN_HASH=6f9a22a8a201c2565b02fadecfb8eb930969985210dcc7f03e88fd1ac3f67618

RUN mkdir /UserMgrPlugin && cd /UserMgrPlugin && \
    curl "${USER_MGR_PLUGIN_URL}" --location --output UserMgrPlugin.zip && \
    echo "${USER_MGR_PLUGIN_HASH}  UserMgrPlugin.zip" | sha256sum --check - && \
    unzip UserMgrPlugin.zip && \
    cp UserMgr/x86-Unicode/UserMgr.dll /usr/share/nsis/Plugins/x86-unicode/ && \
    cp UserMgr/x86-ANSI/UserMgr.dll /usr/share/nsis/Plugins/x86-ansi/ && \
    cd / && rm -rvf /UserMgrPlugin


COPY entrypoint.sh /entrypoint.sh
COPY start.ps1 /start.ps1
COPY p2pool.nsi /p2pool.nsi
COPY header.bmp /header.bmp
COPY welcome.bmp /welcome.bmp
COPY icon.ico /icon.ico
COPY config /config

WORKDIR /tmp

ENTRYPOINT ["/entrypoint.sh"]