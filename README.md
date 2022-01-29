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
Change the password for your BIOS setup:
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
To download the right BIOS Update version from dell please download the bios update from the product site in the manual download section. For example: https://www.dell.com/support/home/de-de/product-support/product/latitude-14-7490-laptop/drivers
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/dell-download.png "SetupInstructions")

## Update for Lenovo
```powershell
"LENOVO" { 
    switch ($Model) {
        "20N3SADW00" { #20N3SADW00 = T490 #Replace Model here
            $EXE = "$PSSCRIPTROOT\LENOVO\$Model\WINUPTP.exe"
            $PARAM = '-s'
            $InstalledBIOSVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
            $InstalledBIOSVersion = $InstalledBIOSVersion.Split("(")
            $InstalledBIOSVersion = $InstalledBIOSVersion[1].replace(' )','')
            $UpdateBIOSVersion = "1.75" #Change Update Version number here

            if ($InstalledBIOSVersion -lt $UpdateBIOSVersion) {
                Write-Host "Installed BIOS Version is older than Update Version"
                Write-Host "Version to install: " + $UpdateBIOSVersion
                Start-Process -FilePath $EXE -ArgumentList $PARAM -Wait
                Copy-Item -Path $PSSCRIPTROOT\WINUPTP.log -Destination "C:\Windows\Logs" -Force
                Restart-Computer -Force
            } else {
                Write-Host "BIOS Update not needed."
            } 
            }
        Default {
            Write-Host "Model not supported by this wrapper!"
        }
    }
}
```
Download the bios update file from the client site at lenovo. For example the T490 site:
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/lenovo-download-1.png "SetupInstructions")
Now extract the bios files:<br>
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/lenovo-download-2.png "SetupInstructions")
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/lenovo-download-3.png "SetupInstructions")
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/lenovo-download-4.png "SetupInstructions")
Now create the folder LENOVO\MODELNAMEHERE and paste the content from the extracted folder (For example: C:\DRIVERS\FLASH\n2iuj30w\20222701.09445940) here.

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
To get the BIOs-Files for the Update for the Installer you need to download the BIOS-System Firmware of your Device off the DELL Support Side:
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/hp-download-1.png "SetupInstructions")
You need to download and install manually:
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/hp-download-2.png "SetupInstructions")
Download the Installer into the created folder (example: HP ProBook 450 G8) of the System you want to add. Then you need to extract the .exe and close the second Installer after installing the first .exe. The only data needed is everything with .bin, .inf and sp_.exe in the folder:
![Alt text](https://github.com/niklasrast/MEM-OpenBIOS-Updater/blob/main/img/hp-download-3.png "SetupInstructions")

# Planed changes
- Add support for Lenovo bios configurations


## Logfiles:
The scripts create a logfile with the name of the manufacturer in the folder C:\Windows\Logs.

## Requirements:
- PowerShell 5.0
- Windows 10 or later

# Feature requests
If you have an idea for a new feature in this repo, send me an issue with the subject Feature request and write your suggestion in the text. I will then check the feature and implement it if necessary.

Created by @niklasrast and @TyroneHelmus
