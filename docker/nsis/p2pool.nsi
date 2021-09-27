!include MUI2.nsh
!include x64.nsh

Unicode True

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
OutFile "p2pool-${VERSION}-windows-x64-installer.exe"
InstallDir "$LOCALAPPDATA\p2pool"
InstallDirRegKey HKCU "Software\p2pool" ""
RequestExecutionLevel user

;-------------------------------------------------------------------------------
; Version Info
VIProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "FileDescription" "${PRODUCT_DESCRIPTION}"
VIAddVersionKey "LegalCopyright" "${COPYRIGHT}"
VIAddVersionKey "FileVersion" "${SETUP_VERSION}"

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\orange.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange.bmp"
!define MUI_FINISHPAGE_NOAUTOCLOSE

!define MUI_WELCOMEPAGE_TEXT "This installer will guide you through setting up P2Pool for Monero. In addition to setup requirements, about 40 GiB will be required for syncing Monero"
!insertmacro MUI_PAGE_WELCOME

!define MUI_PAGE_HEADER_TEXT "P2Pool License (GNU GPL v3.0)"
!define MUI_PAGE_HEADER_SUBTEXT "Please review the P2Pool license before continuing"
!insertmacro MUI_PAGE_LICENSE "LICENSE"

!define MUI_PAGE_HEADER_TEXT "Monero License (MIT)"
!define MUI_PAGE_HEADER_SUBTEXT "Please review the Monero license before continuing"
!insertmacro MUI_PAGE_LICENSE "Monero/LICENSE"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

;!define MUI_FINISHPAGE_RUN "$INSTDIR/start.cmd"
;!define MUI_FINISHPAGE_RUN_TEXT "Start P2Pool and Monero"
!insertmacro MUI_PAGE_FINISH


!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function .onInit
    ${IfNot} ${RunningX64}
        MessageBox MB_OK "p2pool is not supported on 32-bit systems."
        Abort
    ${EndIf}
FunctionEnd

Section "P2Pool and Monero" P2Pool
  SectionIn RO
  SetOutPath "$INSTDIR"

  File /oname=monerod.exe Monero/monerod.exe
  File /oname=p2pool.exe p2pool.exe
  File /oname=monero.LICENSE.txt Monero/LICENSE
  File /oname=p2pool.LICENSE.txt LICENSE
  File /oname=start.ps1 start.ps1

  CreateShortcut "$DESKTOP\P2Pool for Monero.lnk" "powershell.exe" "-noexit -ExecutionPolicy Bypass -File $\"$INSTDIR\start.ps1$\""

  ;Store installation folder
  WriteRegStr HKCU "Software\p2pool" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Uninstall"

  Delete "$DESKTOP\P2Pool for Monero.lnk"
  Delete "$INSTDIR\monerod.exe"
  Delete "$INSTDIR\p2pool.exe"
  Delete "$INSTDIR\start.ps1"
  Delete "$INSTDIR\monero.LICENSE.txt"
  Delete "$INSTDIR\p2pool.LICENSE.txt"
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  DeleteRegKey /ifempty HKCU "Software\p2pool"

SectionEnd