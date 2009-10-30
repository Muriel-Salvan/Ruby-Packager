;--
; Copyright (c) 2009 Muriel Salvan (murielsalvan@users.sourceforge.net)
; Licensed under the terms specified in LICENSE file. No warranty is provided.
;++

; install.nsi
;
; This script creates an installer using NSIS for PBS on Windows.
; The compiler must define the following symbols:
; * VERSION (/DVERSION=0.0.1.20090430)
; * RELEASEDIR ("/DRELEASEDIR=C:\PBS\Releases\MyRelease")

;--------------------------------
; Global attributes
Name "Name"
Caption "Caption"
Icon "Icon.ico"
OutFile "setup.exe"

;--------------------------------
; Compiler tuner
XPStyle on

;--------------------------------
; Default location
InstallDir "$PROGRAMFILES\DummyNSISInstall"

;--------------------------------
; License
LicenseText "LicenseText"
LicenseData "InstallLicense.txt"

;--------------------------------
; List of wizard pages to display
Page license
Page components
Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------
; List of installable components
InstType "Full"

;--------------------------------
; Sections giving what to install

Section "DummySection"
  SectionIn 1 RO
  SetOutPath $INSTDIR
  File /r ${RELEASEDIR}\*.*
SectionEnd
