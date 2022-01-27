<#
    .SYNOPSIS 
    Windows 10 Software packaging wrapper

    .DESCRIPTION
    Install:   C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\OpenBIOSUpdater.ps1 -install
    Uninstall: C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\OpenBIOSUpdater.ps1 -uninstall
    
    .ENVIRONMENT
    PowerShell 5.0
    
    .AUTHOR
    Niklas Rast
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ParameterSetName = 'install')]
	[switch]$install,
	[Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
	[switch]$uninstall
)

$ErrorActionPreference = "SilentlyContinue"
#Use "C:\Windows\Logs" for System Installs and "$env:TEMP" for User Installs
$logFile = ('{0}\{1}.log' -f "C:\Windows\Logs", [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
$BIOSPWD = "MyPassword1"

#Test if registry folder exists
if ($true -ne (test-Path -Path "HKLM:\SOFTWARE\OS")) {
    New-Item -Path "HKLM:\SOFTWARE\" -Name "OS" -Force
}

if ($install)
{
    Start-Transcript -path $logFile -Append
        try
        {         
            #Register package in registry
            New-Item -Path "HKLM:\SOFTWARE\OS\" -Name "OpenBIOSUpdater"
            New-ItemProperty -Path "HKLM:\SOFTWARE\OS\OpenBIOSUpdater" -Name "Version" -PropertyType "String" -Value "1.0.0" -Force

            #Log BIOS 
            Write-Host "Current Version: " + (Get-WmiObject win32_bios).SMBIOSBIOSVersion

            #Detect manufacturer and model
            $manufacturer = (Get-WmiObject win32_computersystemproduct).Vendor
            $Model = ($((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim())

            switch ($manufacturer) {
                "Dell Inc." { 
                    switch ($Model) {
                        "Latitude 7420" { 
                            $EXE = "$PSSCRIPTROOT\DELL\LATITUDE7420\Latitude_7X20_1.14.1.exe"
                            $PARAM = '/s /f /r /p=' + $BIOSPWD + ' /l="C:\Windows\Logs\BIOSUPDATE-7420.log"'
                            $InstalledBIOSVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
                            $UpdateBIOSVersion = "1.14.1"

                            if ($InstalledBIOSVersion -lt $UpdateBIOSVersion) {
                                Write-Host "Installed BIOS Version is older than Update Version"
                                Write-Host "Version to install: " + $UpdateBIOSVersion
                                Start-Process -FilePath $EXE -ArgumentList $PARAM -Wait
                            } else {
                                Write-Host "BIOS Update not needed."
                            } 
                         }
                        "Latitude 9420" { 
                            $EXE = "$PSSCRIPTROOT\DELL\LATITUDE9420\Latitude_9420_1_8_0.exe"
                            $PARAM = '/s /f /r /p=' + $BIOSPWD + ' /l="C:\Windows\Logs\BIOSUPDATE-9420.log"'
                            $InstalledBIOSVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
                            $UpdateBIOSVersion = "1.8.0"

                            if ($InstalledBIOSVersion -lt $UpdateBIOSVersion) {
                                Write-Host "Installed BIOS Version is older than Update Version"
                                Write-Host "Version to install: " + $UpdateBIOSVersion
                                Start-Process -FilePath $EXE -ArgumentList $PARAM -Wait
                            } else {
                                Write-Host "BIOS Update not needed."
                            } 
                         }
                        Default {
                            Write-Host "Model not supported by this wrapper!"
                        }
                    }
                }

                "LENOVO" { 
                    switch ($Model) {
                        "20N3SADW00" { #20N3SADW00 = T490
                            $EXE = "$PSSCRIPTROOT\LENOVO\$Model\WINUPTP.exe"
                            $PARAM = '-s'
                            $InstalledBIOSVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
                            $InstalledBIOSVersion = $InstalledBIOSVersion.Split("(")
                            $InstalledBIOSVersion = $InstalledBIOSVersion[1].replace(' )','')
                            $UpdateBIOSVersion = "1.75"

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

                "HP" {
                    $Model = $Model.replace(' Notebook PC','')
                    switch ($Model)
                    {
                        "HP ProBook 450 G8"
                        {
                            $EXE = "$PSSCRIPTROOT\HP\HpFirmwareUpdRec.exe"
                            $PARAM = '-b -s'
                            $InstalledBIOSVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
                            $InstalledBIOSVersion = $InstalledBIOSVersion.substring($InstalledBIOSVersion.length-8)
                            $UpdateBIOSVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$PSSCRIPTROOT\HP\$Model\sp136413.exe").ProductVersion

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
                        "HP EliteBook 840 G5"
                        {
                            $EXE = "$PSSCRIPTROOT\HP\HpFirmwareUpdRec.exe"
                            $PARAM = '-b -s'
                            $InstalledBIOSVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
                            $InstalledBIOSVersion = $InstalledBIOSVersion.substring($InstalledBIOSVersion.length-8)
                            $UpdateBIOSVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$PSSCRIPTROOT\HP\$Model\sp136471.exe").ProductVersion

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
                Default {
                    Write-Host "Manufacturer not supported by this wrapper!"
                }
            }
            return $true        
        } 
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}

if ($uninstall)
{
    Start-Transcript -path $logFile -Append
        try
        {
            Write-Host "BIOS Updates cannot be removed!"
            return $true     
        }
        catch
        {
            $PSCmdlet.WriteError($_)
            return $false
        }
    Stop-Transcript
}
