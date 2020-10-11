# Add-UsersToTeamsFromCSVFile

[PowerShell](https://docs.microsoft.com/en-us/powershell/) script to add users to teams or to private team channels in [Microsoft Teams](https://teams.microsoft.com/) using a CSV file. Users are added using their email address.

You can install the script by downloading the script from this github page or by installing it directly from the PowerShell Gallery:

[https://www.powershellgallery.com/packages/Add-UsersToTeamsFromCSVFile](https://www.powershellgallery.com/packages/Add-UsersToTeamsFromCSVFile/) 

## Installation Instructions for Windows

Run PowerShell as Administrator, enable powershell script execution and update module to download scripts and modules from the PowerShell Gallery.

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
```

### Restart PowerShell, next install MicrosoftTeams and check installed modules

```powershell
Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.5-preview -AllowPrerelease -force -AllowClobber -Scope CurrentUser
Get-Module -ListAvailable
```

### Install Add-UsersToTeamsFromCSVFile and check installed scripts

```powershell
Install-Script -Name Add-UsersToTeamsFromCSVFile
Get-InstalledScript
```

### Show Help

```powershell
help Add-UsersToTeamsFromCSVFile.ps1
```

## Installation of the script on macOS

Install latest PowerShell using [brew](https://brew.sh) and start the PowerShell.

```bash
brew cask install powershell
pwsh
```

### Install MicrosoftTeams and check the installed modules

```powershell
Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.5-preview -AllowPrerelease -force -AllowClobber
Get-Module -ListAvailable
```

### Install Add-UsersToTeamsFromCSVFile from the PowerShellGallery and check installed scripts

```powershell
Install-Script -Name Add-UsersToTeamsFromCSVFile
Get-InstalledScript
```

Get installed location of powershell gallery scripts.

```powershell
Get-InstalledScript -Name "Add-UsersToTeamsFromCSVFile" | Format-List InstalledLocation
```

Add script path `/Users/[YOUR_USERNAME]/.local/share/powershell/Scripts/` to the path: `$env:PATH += ":/Users/[YOUR_USERNAME]/.local/share/powershell/Scripts/"`.

Start script then with `Add-UsersToTeamsFromCSVFile.ps1`.

## Update script

```powershell
Update-Script Add-UsersToTeamsFromCSVFile
```
