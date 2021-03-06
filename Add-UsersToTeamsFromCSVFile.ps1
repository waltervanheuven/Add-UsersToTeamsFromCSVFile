
<#PSScriptInfo

.VERSION 1.7

.GUID 026e9227-935f-4717-8eea-97813f59400c

.AUTHOR Walter van Heuven

.COMPANYNAME

.COPYRIGHT

.TAGS Microsoft Teams, Teams, Private Channel, Import, CSV

.LICENSEURI

.PROJECTURI https://github.com/waltervanheuven/Add-UsersToTeamsFromCSVFile

.ICONURI

.EXTERNALMODULEDEPENDENCIES
MicrosoftTeams

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
28 April 2021: 1.7 Changed script so that it does not exit when email address is unknown
02 February 2021: 1.6 Fixed issue when adding newly added user to private channel
20 January 2021: 1.5 Bug fixes and changed requirements to MicrosoftTeams 1.1.10-preview
16 October 2020: 1.4
09 October 2020: 1.3
08 October 2020: 1.2
08 October 2020: 1.1
06 October 2020: 1.0 First release on PowerShell Gallery
27 August 2020: Development of this script started with a script written by Jan Derrfuss

.PRIVATEDATA

#>

<#

.SYNOPSIS
Script to add users to teams or to private team channels using a CSV file.

.DESCRIPTION
Script to add users to teams or to private team channels using a CSV file. Users are added using their email address.

Requires MicrosoftTeams 1.1.10-preview.

Install-Module -Name MicrosoftTeams -RequiredVersion 1.1.10-preview -AllowPrerelease

Run Connect-MicrosoftTeams to connect to the AzureCloud before running this script.

You can only add users if you are the owner of the team.

To add users to a teams, the CSV file requires 2 columns, separated by a comma.
First line of CSV file is a header indicating the column names: email, team

To add users to private channels in a team, the CSV file requires 3 columns, separated by commas.
First line of CSV file is a header indicating the column names: email, team, privatechannel

An additional column in the CSV file 'role' is optional, default role of user added is Member.

The team column should indate the name of the team and the privatechannel should indicate
the name of the private channel. Note that when a user is not a member of the team it will
be added to the team first before it is added to the private channel.

Script reports start and end time as well as the number of users added to teams and channels.

.PARAMETER CSVFileToProcess
Name of the CSV file with at least two columns: email, team

.EXAMPLE
Add-UsersToTeamsFromCSVFile.ps1 -CSVFileToProcess .\students.csv

students.csv

	email, team
	student1@university.ac.uk, Module1 Team
	student2@university.ac.uk, Module1 Team
	student1@university.ac.uk, Module2 Team
	student2@university.ac.uk, Module2 Team

Script adds two students to two teams.

Please note that the team name should be surrounded by quotes when the name contains a comma or quotes.

.EXAMPLE
Add-UsersToTeamsFromCSVFile.ps1 .\students.csv

-CSVFileToProcess is optional.

Content of file: students.csv

	email, team
	student1@university.ac.uk, Module1 Team
	student2@university.ac.uk, Module1 Team

Script adds two students to the team: Module1 Team.

.EXAMPLE
Add-UsersToTeamsFromCSVFile.ps1 .\students.csv

Content of file: students.csv

	email, team, privatechannel
	student1@university.ac.uk, Module1 Team, Lab1
	student2@university.ac.uk, Module1 Team, Lab2

Script adds two students to private channels within the same team.

.EXAMPLE
Add-UsersToTeamsFromCSVFile.ps1 .\users.csv

Content of file: users.csv

	email, team, privatechannel, role
	student1@university.ac.uk, "Module's Team", Lab1, Member
	lab.demonstrator1@university.ac.uk, "Module's Team", Lab1, Member

Script adds two users to private channels with the same team. Column 'role' indicates their role.

.EXAMPLE
Add-UsersToTeamsFromCSVFile.ps1 .\users.csv -Debug

Script provides also debug information. Useful when errors occur.

#>

#Requires -Module @{ModuleName = 'MicrosoftTeams'; RequiredVersion = '1.1.10'}

Param (
	[Parameter(ParameterSetName = "Inputparameter", Position = 0, HelpMessage="Input CSV file: ", Mandatory = $true)]
	[String] $CSVFileToProcess
)

# BEGIN
$startTime = Get-Date -DisplayHint Date

# Check if input file is provided
if ([string]::IsNullOrEmpty($CSVFileToProcess)) {
	Write-Error "Input CSV file missing"
	EXIT
}

# Check if file exists and has required columns
if (Test-Path -LiteralPath $CSVFileToProcess -PathType Leaf) {
	Write-Output "Processing CSV file: $CSVFileToProcess"

	$inputCsvFile = Import-Csv -Path $CSVFileToProcess

	# check CSV file
	$colCount = ($inputCsvFile | get-member -type NoteProperty).Count
	if ($colCount -lt 2) {
		Write-Error "Error in file: '$CSVFileToProcess', at least 2 columns needed, found: $colCount"
		Write-Error "Required columns in the CSV file: email, team"
		Write-Error "Additional column needed when adding students to channel: privatechannel"
		Write-Error "Optional column: role, if missing, role is Member"
		EXIT
	}

	#
	$n = 2
	$addedTeamMembers = 0
	$addedChannelMembers = 0
	$currentTeam = ""
	[System.Collections.ArrayList] $currentTeamMembers = @()
	$currentChannel = ""
	[System.Collections.ArrayList] $currentChannelMembers = @()
	$changedTeam = 0

	$theEmail = ""
	$theTeam = ""
	$theChannel = ""
	$theRole = ""

	#
	foreach ($line in $inputCsvFile) {

		if ([string]::IsNullOrEmpty($line.email)) {
			Write-Error "Line $n, column 'email' is empty or column 'email' is missing"
			EXIT
		} else {
			try {
				$null = [mailaddress]$line.email
				$theEmail = $line.email
			}
			catch {
				Write-Error "Line $n, email: '$($line.email)' not in not a valid email address"
				EXIT
			}
		}
		if ([string]::IsNullOrEmpty($line.team)) {
			Write-Error "Line $n, column 'team' is empty or column 'team' missing"
			EXIT
		} else {
			$theTeam = $line.team
		}

		# check if Role column is available, if not set Role to Member
		if ([string]::IsNullOrEmpty($line.role)) {
			$theRole = "Member"
		} else {
			$theRole = $line.role
		}

		if ([string]::IsNullOrEmpty($line.privatechannel)) {
			$theChannel = ""
		} else {
			$theChannel = $line.privatechannel
		}

		# Team
		if ($currentTeam -ne $theTeam) {
			try {
				Write-Output "Obtaining GroupID and current members from team... (this can take some time)"
				if ($PSBoundParameters.ContainsKey('Debug')) {
					Write-Debug "Obtaining GroupID from team: $theTeam"
				}

				$grpid = (Get-Team -DisplayName $theTeam) | Select-Object -ExpandProperty GroupId
				if ($null -eq $grpid) {
					Write-Error "Line $n, Get-Team: GroupID of '$theTeam' is null"
					EXIT
				}

				[System.Collections.ArrayList] $currentTeamMembers = @()
				$list = (Get-TeamUser -GroupId $grpid) | Select-Object -ExpandProperty User
				foreach ($m in $list) {
					[void] $currentTeamMembers.Add($m)
				}

				if ($PSBoundParameters.ContainsKey('Debug')) {
					Write-Debug "Current members:"
					$currentTeamMembers | Write-Debug
				}

				$currentTeam = $theTeam
				$changedTeam = 1
			}
			catch {
				if ($PSBoundParameters.ContainsKey('Debug')) {
					Write-Error $_.Exception.Message
				}
				Write-Error "Line $n, Get-Team: Unable to connect to MicrosoftTeams (AzureCloud)"
				Write-Error "Before running this script enter: Connect-MicrosoftTeams"
				EXIT
			}
		} else {
			$changedTeam = 0
		}

		if ($currentTeamMembers -Contains $theEmail) {
			# do not warn when adding people to a private channel within a team
			if ($theChannel -eq "") {
				Write-Warning "Line $n, $theEmail already member of team: $theTeam"
			}
		} else {
			try {
				$oldN = ((Get-TeamUser -GroupId $grpid) | Select-Object -ExpandProperty User).count
				Add-TeamUser -GroupId $grpid -User $theEmail -Role $theRole
				Write-Output "Line $n, added: '$theEmail', role: '$theRole' to team: '$theTeam'"
				$addedTeamMembers += 1

				[void] $currentTeamMembers.Add($theEmail)

				if ($theChannel -ne "") {
					# sleep 5 seconds to allow AzureCloud update
					Start-Sleep -s 5

					# make sure newly added user is indeed added, if not wait further until AzureCloud updates
					$newN = ((Get-TeamUser -GroupId $grpid) | Select-Object -ExpandProperty User).count
					$waitCnt = 0
					while ($newN -le $oldN) {
						if ($PSBoundParameters.ContainsKey('Debug')) {
							Write-Output "Sleep..."
						}
						Start-Sleep -s 1
						$newN = ((Get-TeamUser -GroupId $grpid) | Select-Object -ExpandProperty User).count
						$waitCnt += 1
						if ($waitCnt -gt 30) {
							Write-Debug "Timeout Error. Unable to add user. Please try again."
							EXIT
						}
					}
				}

				if ($PSBoundParameters.ContainsKey('Debug')) {
					Write-Debug "Members:"
					$currentTeamMembers | Write-Debug
				}
			}
			catch {
				if ($PSBoundParameters.ContainsKey('Debug')) {
					Write-Error $_.Exception.Message
				}
				Write-Error "Line $n, Error when executing Add-TeamUser. Unknown email address: '$theEmail' (not a user)"
				#EXIT
			}
		}

		# Channel
		if ($theChannel -ne "") {
			if (($currentChannel -ne $theChannel) -or ($changedTeam -eq 1)) {
				try {
					[System.Collections.ArrayList] $currentChannelMembers = @()
					$list = (Get-TeamChannelUser -GroupId $grpid -DisplayName $theChannel) | Select-Object -ExpandProperty User
					foreach ($m in $list) {
						[void] $currentChannelMembers.Add($m)
					}

					if ($PSBoundParameters.ContainsKey('Debug')) {
						Write-Debug "Current private channel member:"
						$currentChannelMembers | Write-Debug
					}
				}
				catch {
					if ($PSBoundParameters.ContainsKey('Debug')) {
						Write-Error $_.Exception.Message
					}
					Write-Error "Line $n, Error when executing Get-TeamChannelUser"
					EXIT
				}
				$currentChannel = $theChannel
			}

			if ($currentChannelMembers -Contains $theEmail) {
				Write-Warning "Line $n, $theEmail already member of private channel: $theChannel"
			} else {
				try {
					if ($theRole -eq "Owner") {
						Add-TeamChannelUser -GroupId $grpid -DisplayName $theChannel -User $theEmail -Role $theRole
					} else {
						Add-TeamChannelUser -GroupId $grpid -DisplayName $theChannel -User $theEmail
					}
					Write-Output "Line $n, added: '$theEmail', to private channel: '$theChannel' in team: '$theTeam'"
					$addedChannelMembers += 1
					[void] $currentChannelMembers.Add($theEmail)

					if ($PSBoundParameters.ContainsKey('Debug')) {
						Write-Debug "Private channel members:"
						$currentChannelMembers | Write-Debug
					}
				}
				catch {
					if ($PSBoundParameters.ContainsKey('Debug')) {
						Write-Error $_.Exception.Message
					}
					Write-Error "Line $n, Error when executing Add-TeamChannelUser, user: '$theEmail', channel: '$theChannel'"
					EXIT
				}
			}
		}
		$n += 1
	}
	$endTime = Get-Date -DisplayHint Date

	Write-Output "Finished processing file: '$CSVFileToProcess'"
	Write-Output "Start time: $startTime"
	Write-Output "End time: $endTime"
	Write-Output "Total number of people added to teams: $addedTeamMembers"
	Write-Output "Total number of people added to private channels: $addedChannelMembers"
} else {
	Write-Error "Input file: '$CSVFileToProcess' does not exist"
	EXIT
}
