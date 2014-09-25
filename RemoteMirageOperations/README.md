# Invoke-RemoteMirageOperation.ps1

This script allows remote execution of different Mirage operations like centralize an endpoint, base layer assignment and so on.
It is designed to be run on a Mirage client using 3rd party deployment systems like SCCM.
This allows to trigger certain Mirage operations as part of your current deployment task sequence.
Also it is possible to use this script in automation and orchestration tools like VMware vCenter Orchestrator.

## Prerequsists
This scripts requires to following things to work:
- PowerShell 2.0
- PowerShell remoting enabled on the Mirage management server (see below on how to active it)
- Account with Mirage administrative rights is required to run the script

This script was succesfully tested with Mirage version 4.3, 5.0 and 5.1.

## Usage
The script by default expectes to be run on a systeme where the Mirage client is installed.
Therefore the scripts fails if no Mirage client is found. The reasons for this is that the Mirage log file location is used to create the default log.
To run the script on a system where no Mirage client is present either specifiy a different log file location (using the -LogFile parameter) or disable logging altogether (using the -LogLevel NONE parameter).

The paramters and usage example of the script can be found in the using the default PowerShell help command:

Get-Help Invoke-RemoteMirageOperation.ps1 -full

## Enable PowerShell remoting on the Mirage management server
To use this script PowerShell remoting needs to be enabled on the Mirage management server.
The easiest way to do so is to run the 'Enable-PSRemoting' command in an administrative PowerShell console on the Mirage management server.

Please keep in mind that default security is used that may not comply with your organisations security rules.

## Disclaimer
No Warranty. This script is provided "as is" without warranty of any kind, either express or implied, including without limitation any implied warranties of condition, uninterrupted use, merchantability, fitness for a particular purpose, or non-infringement.
