;--
; Copyright (c) 2009 - 2012 Muriel Salvan (muriel@x-aeon.com)
; Licensed under the terms specified in LICENSE file. No warranty is provided.
;++

; install.nsi
;
; This script creates an installer using NSIS for a simple test program
; The compiler must define the following symbols:
; * VERSION (/DVERSION=0.0.1.20090430)
; * RELEASEDIR ("/DRELEASEDIR=C:\Releases\MyRelease")

;--------------------------------
; Global attributes
Name "BasicTest"
Caption "Basic Testing - Hello World"
Icon "Icon.ico"
OutFile "setup.exe"

;--------------------------------
; Compiler tuner
XPStyle on

;--------------------------------
; Default location
InstallDir "$PROGRAMFILES\Test"

;--------------------------------
; License
LicenseText "Welcome to HelloWorld installation (v. ${VERSION})."
LicenseData "InstallLicense.txt"

;--------------------------------
; List of wizard pages to display
Page license
Page components
Page directory
Page instfiles

;--------------------------------
; List of installable components
InstType "Full"

;--------------------------------
; Sections giving what to install

Section "Core"
  SectionIn 1 RO
  SetOutPath $INSTDIR
  File /r ${RELEASEDIR}\*.*
SectionEnd
