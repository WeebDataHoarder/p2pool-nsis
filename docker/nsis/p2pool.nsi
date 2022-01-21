!include MUI2.nsh
!include nsDialogs.nsh
!include LogicLib.nsh
!include x64.nsh

SetCompressor /SOLID lzma
SetCompressorDictSize 64
SetDateSave off
SetOverwrite on

CRCCheck on
Unicode True
Var Dialog
Var P2PoolConfig
Var MoneroAddress
Var MoneroWalletAddress
Var P2PoolConfigSetting

;-------------------------------------------------------------------------------
; Constants
!define VERSION "$%P2POOL_VERSION%"
!define PRODUCT_NAME "P2Pool for Monero"
!define PRODUCT_DESCRIPTION "P2Pool for Monero"
!define COPYRIGHT ""
!define PRODUCT_VERSION "1.0.0.0"
!define SETUP_VERSION 1.0.0.0

;-------------------------------------------------------------------------------
; Attributes
Name "P2Pool for Monero ${VERSION}"
OutFile "p2pool-${VERSION}-windows-x64-installer_$%GIT_HASH%.exe"
InstallDir "$LOCALAPPDATA\p2pool"
InstallDirRegKey HKCU "Software\p2pool" ""
RequestExecutionLevel user
ShowInstDetails show
ShowUninstDetails show
BrandingText "p2pool.io :: github.com/WeebDataHoarder/p2pool-nsis"
ManifestDPIAware true
ManifestSupportedOS Win7 Win8 Win8.1 Win10

;-------------------------------------------------------------------------------
; Version Info
VIProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "FileDescription" "${PRODUCT_DESCRIPTION}"
VIAddVersionKey "LegalCopyright" "${COPYRIGHT}"
VIAddVersionKey "FileVersion" "${SETUP_VERSION}"

!define MUI_BGCOLOR "FF6600"
;!define MUI_TEXTCOLOR "4C4C4C"
Icon "icon.ico"
!define MUI_ICON "icon.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

!define MUI_WELCOMEPAGE_TEXT "This installer will guide you through setting up P2Pool for Monero. Setup requirements include about 40 GiB extra that will be used for syncing Monero"
!insertmacro MUI_PAGE_WELCOME

!define MUI_PAGE_HEADER_TEXT "P2Pool License (GNU GPL v3.0)"
!define MUI_PAGE_HEADER_SUBTEXT "Please review the P2Pool license before continuing"
!insertmacro MUI_PAGE_LICENSE "p2pool.LICENSE"

!define MUI_PAGE_HEADER_TEXT "Monero License (MIT)"
!define MUI_PAGE_HEADER_SUBTEXT "Please review the Monero license before continuing"
!insertmacro MUI_PAGE_LICENSE "monero.LICENSE"

!define MUI_COMPONENTSPAGE_NODESC
!define MUI_COMPONENTSPAGE_TEXT_TOP "Select any components you want to install. Huge Pages requires starting this installer as Administrator and a reboot to apply."
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
Page custom walletPageCreate walletPageLeave
!insertmacro MUI_PAGE_INSTFILES

;!define MUI_FINISHPAGE_RUN "$INSTDIR/start.cmd"
;!define MUI_FINISHPAGE_RUN_TEXT "Start P2Pool and Monero"

!define MUI_FINISHPAGE_REBOOTLATER_DEFAULT 1
!define MUI_FINISHPAGE_TEXT_REBOOT "If you enabled Huge Pages as an Administrator you will have to reboot for them to take effect."
!insertmacro MUI_PAGE_FINISH


!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function walletPageCreate


    ${If} ${FileExists} "$INSTDIR\wallet.txt"
        FileOpen $4 "$INSTDIR\wallet.txt" r
        FileRead $4 $1
        FileClose $4
        FileOpen $4 "$INSTDIR\wallet.txt" r
        FileReadUTF16LE $4 $2
        FileClose $4

        StrLen $4 $1
        StrLen $5 $2
        ${If} $5 > $4
            StrCpy $MoneroWalletAddress $2
        ${Else}
            StrCpy $MoneroWalletAddress $1
        ${EndIf}
    ${EndIf}

    !insertmacro MUI_HEADER_TEXT "Monero Address Settings" "Provide a Monero Payout Address for P2Pool. Can be edited later"

    nsDialogs::Create 1018
    Pop $Dialog

    ${If} $Dialog == error
        Abort
    ${EndIf}

    ${NSD_CreateGroupBox} 10% 10u 80% 80% "P2Pool Settings"
    Pop $0

        ${NSD_CreateLabel} 20% 26u 20% 10u "Sidechain:"
        Pop $0

        ${NSD_CreateDropList} 40% 24u 40% 12u ""
        Pop $P2PoolConfig
          ${NSD_CB_AddString} $P2PoolConfig "main"
          ${NSD_CB_AddString} $P2PoolConfig "mini"
          ${NSD_CB_SelectString} $P2PoolConfig "main"

        ${NSD_CreateLabel} 20% 40u 20% 10u "Monero Address:"
        Pop $0

        ${NSD_CreateText} 40% 38u 40% 12u "$MoneroWalletAddress"
        Pop $MoneroAddress

        ${NSD_CreateLabel} 20% 56u 60% 10u "Only Primary Address supported (starts with 4)"
        Pop $0

    nsDialogs::Show
FunctionEnd

Function walletPageLeave
    ${NSD_GetText} $MoneroAddress $MoneroWalletAddress
    ${NSD_GetText} $P2PoolConfig $P2PoolConfigSetting
FunctionEnd

Section "p2pool" p2pool
  SectionIn 1 RO
  SetOutPath "$INSTDIR"

  # Add extra 500 MiB to account for p2pool cache
  AddSize 512000

  File /oname=p2pool.exe p2pool.exe
  File /oname=p2pool.LICENSE.txt p2pool.LICENSE
  File /oname=start.ps1 start.ps1
  File /oname=icon.ico icon.ico

  ${If} $P2PoolConfigSetting == "main"
    File /oname=config.json config/main.json
  ${EndIf}
  ${If} $P2PoolConfigSetting == "mini"
    File /oname=config.json config/mini.json
  ${EndIf}

  FileOpen $9 wallet.txt w
  FileWrite $9 "$MoneroWalletAddress"
  FileClose $9

  CreateShortcut "$DESKTOP\P2Pool for Monero.lnk" "powershell.exe" "-noexit -ExecutionPolicy Bypass -File $\"$INSTDIR\start.ps1$\"" "$INSTDIR\icon.ico" 0

  ;Store installation folder
  WriteRegStr HKCU "Software\p2pool" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd


Section "monerod" monerod
  SectionIn 1 RO
  SetOutPath "$INSTDIR"

  File /oname=monerod.exe monerod.exe
  File /oname=monero.LICENSE.txt monero.LICENSE
SectionEnd

#Section "xmrig"
#  SetOutPath "$INSTDIR"
#
#  File /oname=xmrig.exe xmrig.exe
#  File /oname=.xmrig.json xmrig.json
#SectionEnd

Section "Enable Huge Pages" P2PoolHugePages
  UserMgr::GetCurrentDomain
  Pop $0

  UserMgr::GetCurrentUserName
  Pop $1
  DetailPrint "Enabling Huge Pages for $0\$1"

  UserMgr::AddPrivilege "$0\$1" "SeLockMemoryPrivilege"
  Pop $0
  DetailPrint "Huge Pages: $0"
  ${If} $0 == "OK"
    SetRebootFlag true
  ${EndIf}

SectionEnd




Section "un.p2pool" un.p2pool
  Delete "$DESKTOP\P2Pool for Monero.lnk"
  Delete "$INSTDIR\p2pool.exe"
  Delete "$INSTDIR\start.ps1"
  Delete "$INSTDIR\icon.ico"
  Delete "$INSTDIR\config.json"
  Delete "$INSTDIR\p2pool.LICENSE.txt"
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"
  DeleteRegKey /ifempty HKCU "Software\p2pool"

SectionEnd

Section "un.monerod" un.monerod
  Delete "$INSTDIR\monerod.exe"
  Delete "$INSTDIR\monero.LICENSE.txt"

  RMDir "$INSTDIR"

SectionEnd

Section "un.Monero Blockchain"
  Delete "$INSTDIR\bitmonero.log"
  Delete "$INSTDIR\lmdb\data.mdb"
  Delete "$INSTDIR\lmdb\lock.mdb"
  RMDir "$INSTDIR\lmdb"
  Delete "$INSTDIR\p2pstate.bin"

  RMDir "$INSTDIR"

SectionEnd

Section "un.p2pool data"

  Delete "$INSTDIR\p2pool.blocks"
  Delete "$INSTDIR\p2pool.cache"
  Delete "$INSTDIR\p2pool.log"
  Delete "$INSTDIR\p2pool_peers.txt"

  RMDir "$INSTDIR"

SectionEnd

Section "un.p2pool remembered wallet"
  Delete "$INSTDIR\wallet.txt"

  RMDir "$INSTDIR"

SectionEnd



Function .onInit
    ${IfNot} ${RunningX64}
        MessageBox MB_OK "p2pool is not supported on 32-bit systems."
        Abort
    ${EndIf}
    InitPluginsDir
    StrCpy $MoneroWalletAddress ""

      ${IfNot} ${FileExists} "$INSTDIR\lmdb\data.mdb"
        # Add extra 40 GiB to account for Monero pruned blockchain
        SectionGetSize ${monerod} $0
        IntOp $0 $0 + 42949672960
        SectionSetSize ${monerod} $0
      ${EndIf}
FunctionEnd