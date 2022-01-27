# MEM-OpenBIOS-Updater

![GitHub repo size](https://img.shields.io/github/repo-size/niklasrast/MEM-OpenBIOS-Updater)

![GitHub issues](https://img.shields.io/github/issues-raw/niklasrast/MEM-OpenBIOS-Updater)

![GitHub last commit](https://img.shields.io/github/last-commit/niklasrast/MEM-OpenBIOS-Updater)

This repo contains an powershell script to update bios versions on lenovo, dell and hp clients trough any software deployment solution. Im using Microsoft Intune to deploy the configuration

## Software deployment configuration calls:

### Install:
- C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\OpenBIOSUpdater.ps1 -install

### Detect:
- RegKey: HKLM:\SOFTWARE\OS\OpenBIOSUpdater
- RegKey: Version
- RegKey: 1.0.0
 
<hr>

## Customisation:
```powershell
$BIOSPWD = "MyPassword1"

```

## Updater for DELL:
```powershell
"Dell Inc." { 
  switch ($Model) {
     "Latitude 7420" { #Change Model here
         $EXE = "$PSSCRIPTROOT\DELL\LATITUDE7420\Latitude_7X20_1.14.1.exe" #Change EXE Filename here
         $PARAM = '/s /f /r /p=' + $BIOSPWD + ' /l="C:\Windows\Logs\BIOSUPDATE-7420.log"' #Change Model here
         $InstalledBIOSVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
         $UpdateBIOSVersion = "1.14.1" #Change Update Version here

         if ($InstalledBIOSVersion -lt $UpdateBIOSVersion) {
             Write-Host "Installed BIOS Version is older than Update Version"
             Write-Host "Version to install: " + $UpdateBIOSVersion
             Start-Process -FilePath $EXE -ArgumentList $PARAM -Wait
         } else {
             Write-Host "BIOS Update not needed."
         } 
      }
      Default
      {
          Write-Host "Model not supported by this wrapper!"
      }
}
                    
```

## Update for HP
```powershell
"HP" {
  $Model = $Model.replace(' Notebook PC','')
  switch ($Model)
  {
      "HP ProBook 450 G8" #Change Model here
      {
          $EXE = "$PSSCRIPTROOT\HP\HpFirmwareUpdRec.exe"
          $PARAM = '-b -s'
          $InstalledBIOSVersion = (gwmi win32_bios).SMBIOSBIOSVersion
          $InstalledBIOSVersion = $InstalledBIOSVersion.substring($InstalledBIOSVersion.length-8)
          $UpdateBIOSVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$PSSCRIPTROOT\HP\$Model\sp136413.exe").ProductVersion #Change EXE Filename here

          if ($InstalledBIOSVersion -lt $UpdateBIOSVersion) {
              Write-Host "Installed BIOS Version is older than Update Version"
              Write-Host "Version to install: $UpdateBIOSVersion"
              Start-Process -FilePath $EXE -ArgumentList $PARAM -Wait
          }               
          else
          {
              Write-Host "BIOS Update not needed."
          }     
      }

      Default
      {
          Write-Host "Model not supported by this wrapper!"
      }
  }                 
}
```

# Planed changes
- Add support for Lenovo bios configurations
- Add support for HP bios configurations


## Logfiles:
The scripts create a logfile with the name of the manufacturer in the folder C:\Windows\Logs.

## Requirements:
- PowerShell 5.0
- Windows 10 or later

# Feature requests
If you have an idea for a new feature in this repo, send me an issue with the subject Feature request and write your suggestion in the text. I will then check the feature and implement it if necessary.

Created by @niklasrast and @TyroneHelmus
