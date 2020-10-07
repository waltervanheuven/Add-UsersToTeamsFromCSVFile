# Add-UsersToTeamsFromCSVFile

[PowerShell](https://docs.microsoft.com/en-us/powershell/) script to add users to teams or to private team channels in [Microsoft Teams](https://teams.microsoft.com/) using a CSV file. Users are added using their email address.

You can install the script by downloading the script from this github page or by installing it directly from the PowerShell Gallery:

[https://www.powershellgallery.com/packages/Add-UsersToTeamsFromCSVFile](https://www.powershellgallery.com/packages/Add-UsersToTeamsFromCSVFile/) 

# Installation Instructions for Windows

Assuming PowerShell 5.1 (installed on Windows 10)

Run PowerShell as Administrator

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
```

## Restart PowerShell, next install MicrosoftTeams and check installed modules

```powershell
Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.5-preview -AllowPrerelease -force -AllowClobber -Scope CurrentUser
Get-Module -ListAvailable
```

## Install Add-UsersToTeamsFromCSVFile and check installed scripts

```powershell
Install-Script -Name Add-UsersToTeamsFromCSVFile
Get-InstalledScript
```

## Show Help

```powershell
help Add-UsersToTeamsFromCSVFile.ps1
```

# Installation on macOS

Install latest PowerShell using [brew](https://brew.sh) and start the PowerShell.

```bash
brew cask install powershell
pwsh
```

## Install MicrosoftTeams and check the installed modules

```powershell
Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.5-preview -AllowPrerelease -force -AllowClobber
Get-Module -ListAvailable
```

## Install Add-UsersToTeamsFromCSVFile from the PowerShellGallery and check installed scripts

```powershell
Install-Script -Name Add-UsersToTeamsFromCSVFile
Get-InstalledScript
```

Note that there is an issue with the PowerShell on macOS. The script path is not included in the search path and therefore installed scripts from the [powershellgallery](https://www.powershellgallery.com) are not found. You can find the installed location of the script using this command

```powershell
Get-InstalledScript -Name "Add-UsersToTeamsFromCSVFile" | Format-List InstalledLocation
```

Use that location when starting the script.

Start script then with:

```powershell
/Users/[YOUR_USERNAME]/.local/share/powershell/Scripts/Add-UsersToTeamsFromCSVFile.ps1
```
