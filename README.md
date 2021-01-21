# Add-UsersToTeamsFromCSVFile

[PowerShell](https://docs.microsoft.com/en-us/powershell/) script to add users to teams or to private team channels in [Microsoft Teams](https://teams.microsoft.com/) using a CSV file. Users are added using their email address.

You can install the script by downloading the script from this github page or by installing it directly from the PowerShell Gallery:

[https://www.powershellgallery.com/packages/Add-UsersToTeamsFromCSVFile](https://www.powershellgallery.com/packages/Add-UsersToTeamsFromCSVFile/1.4)

## Installation instructions for Windows

Download and install the latest version (7.1) of the PowerShell from [github.com/PowerShell/PowerShell](https://github.com/PowerShell/PowerShell)

Start PowerShell 7 from the Start Menu and install MicrosoftTeams module

```powershell
Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.10-preview -AllowPrerelease
```

Install Add-UsersToTeamsFromCSVFile script

```powershell
Install-Script -Name Add-UsersToTeamsFromCSVFile
```

## Installation instructions for macOS

Install PowerShell using [brew](https://brew.sh) in the Terminal App.

```sh
brew install powershell
```

Start powershell in Terminal

```sh
pwsh
```

Install MicrosoftTeams and Script

```powershell
Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.10-preview -AllowPrerelease
Install-Script -Name Add-UsersToTeamsFromCSVFile
```

Get installed location of powershell gallery scripts.

```powershell
Get-InstalledScript -Name "Add-UsersToTeamsFromCSVFile" | Format-List InstalledLocation
```

Add script path `/Users/[YOUR_USERNAME]/.local/share/powershell/Scripts/` to the path: `$env:PATH += ":/Users/[YOUR_USERNAME]/.local/share/powershell/Scripts/"`.

## Check that module and script are installed

```powershell
Get-Module -ListAvailable
Get-InstalledScript
```

## Show Help

```powershell
help Add-UsersToTeamsFromCSVFile.ps1
```

## Update script to latest version

```powershell
Update-Script Add-UsersToTeamsFromCSVFile
```

## CSV file

The script requires a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) file. This file should contain a header with the names of the columns. To add users to a team, the CSV file needs to have the columns 'email' and 'team'.

```txt
email,team
student1@university.ac.uk,Module1 Team
student2@university.ac.uk,Module1 Team
student1@university.ac.uk,Module2 Team
student2@university.ac.uk,Module2 Team
```

To add users to a private channel in a team, the CSV file needs to have the columns 'email', 'team', and 'privatechannel'. If a user is not a member of the team they will be added to the team first and then to the private channel within the team.

```txt
email,team,privatechannel
student1@university.ac.uk,Seminar Group,Channel1
student2@university.ac.uk,Seminar Group,Channel1
student3@university.ac.uk,Seminar Group,Channel2
student4@university.ac.uk,Seminar Group,Channel2
```

## Usage

```powershell
# First connect to Microsoft Teams (AzureCloud)
Connect-MicrosoftTeams

# run script
Add-UsersToTeamsFromCSVFile.ps1 students.csv
```
