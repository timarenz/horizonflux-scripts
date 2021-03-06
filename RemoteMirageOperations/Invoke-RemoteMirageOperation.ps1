#Requires -version 2

<#

  .SYNOPSIS 
    Remotely executes a Mirage operation on a Mirage management server.
   
  .DESCRIPTION
    This script can be used to trigger Mirage operations from a third party system.
    It allows to execute basic Mirage operations (centralization, layer assignment, provisioning, etc.) remotely.
    As source system any system running PowerShell version 2 can be used.
    The target system has to be a Mirage management system with PowerShell remoting activated.

  .PARAMETER AssignCVDPolicy
   Assign a CVD policy to a CVD.

  .PARAMETER Centralize
    This parameter triggers a centralization operation.

  .PARAMETER AssignBaseLayer
    Using this parameter a base layer can be assigned or updated.

  .PARAMETER AddAppLayer
    Using this parameter a application layer can be assigned or updated.

  .PARAMETER Provisioning
    This parameter is used to provision a base layer to a new system.

  .PARAMETER Migration
    Using this parameter a Windows migration can be triggered.

  .PARAMETER EnforceLayers
    To enforce layers use this parameter.

  .PARAMETER Restore
    This parameter can be used to do a hardware migration or computer restore.
    Behind the scenes the same task (assigndevicetoExistingCvd) is used for both.

  .PARAMETER LayerId
    Specifies the id of base or app layer that can be assigned using the following operations:
    AddAppLayer, AssignBaseLayer, Migration, Provisioning 

  .PARAMETER LayerVersion
    Specifies the version of the layer that should be assigned when the parameter LayerId is used.

  .PARAMETER PolicyId
    Specifies the id of the CVD policy that can be assigned using the following operations:
    Centralize, Provisioning 

  .PARAMETER PolicyVersion
    Specifies the version of the CVD policy that should be assigned when the parameter PolicyId is used.

  .PARAMETER TargetDomain
    Specifies the Active Directory domain that should be joined during the following operations:
    Migration, Provisioning

  .PARAMETER TargetOU
    Specifies the organizational unit (OU) that should be joined during the following operations:
    Migration, Provisioning

    The OU needs to be specified in LDAP notation.
    Example: "OU=Win7,OU=DEV,OU=Domain Clients,DC=eucware,DC=com"

  .PARAMETER RemoveUserApps
    Specifies if user installed applications should be removed during the following operation:
    EnforceLayers

  .PARAMETER DownloadOnly
    If this option is specified the migration will not be started but only the base layer will be downloaded to the end point.
    This parameter can used during the following operation:
    Migration

  .PARAMETER TargetName
    This parameter can be used in two different ways.

    When used while the Migration option is specified this parameter defines if the computer name should be changed during the migration.
    If the parameter TargetName is set the computer name will be changed to the specified name during the migration. 
    If not the computer name will not be changed and the current computer name will be used.

    When this parameter is used in combination with the Restore option it specifies the target machine on which the restore should be done.

  .PARAMETER SourceName
    This parameter specifies for which computer (CVD) Mirage operations should be invoked
    By default the name of the computer this script is run on will be used as SourceName.

  .PARAMETER LogLevel
    This parameter specifies the log level.
    Available log levels are:
    NONE - Nothing is displayed during script execution.
    VERBOSE - Display additional (verbose) information.
    INFO - Default log level.

    By default all data is written to a log file in verbose mode. This parameter controls only which data is displayed during script execution.
  
  .PARAMETER LogFile
    Specifies the file in which the log output should be written to.
    By default it's a file called "Invoke-RemoteMirageOperation.log" in the default Mirage client log directory (C:\Program Files\Wanova\Mirage Service\Logs).

  .PARAMETER Server
    Specifies the Mirage management server on which the remote operation should be executed.
    The server must meet the following software requirements.
    
    - VMware Mirage management server needs to be installed
    - PowerShell remoting needs to be enabled

  .PARAMETER User
    Specifies a user account that should be used to connect to the remote Mirage management server.
    This user needs Mirage administrative rights to execute Mirage operations.
    By default the current user executing this script is used.

  .PARAMETER Domain
    Specifies the domain for the user account that should be used to connect to the remote Mirage management server.

  .PARAMETER Password
    Specifies the password for the user account that should be used to connect to the remote Mirage management server.

  .INPUTS
    None. You cannot pipe objects to Invoke-RemoteMirageOperation.

  .OUTPUTS
    System.Boolean. Invoke-RemoteMirageOperation returns a boolean.
    0 for a succesfull exectution, 1 for a failed execution.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -AssignCVDPolicy -PolicyId 3 -PolicyVersion 1.0 -Server mirage.eucware.com

    Assigns the CVD policy with the Id 3 and version 1.0 to the current computer on which this script runs.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -Centralize -PolicyId 3 -PolicyVersion 1.0 -Server mirage.eucware.com

    Centralize the current computer on which this script runs.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -Centralize -PolicyId 3 -PolicyVersion 1.0 -LayerId 1 -LayerVersion 5.0 -Server mirage.eucware.com

    Centralize the current computer on which this script runs and assign a base layer during the same operation.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -AssignBaseLayer -LayerId 1 -LayerVersion 5.0 -Server mirage.eucware.com

    Assign a base layer to the current computer on which the script runs on.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -AssignBaseLayer -LayerId 1 -LayerVersion 6.0 -Server mirage.eucware.com -SourceName MyComputer

    Assign a base layer to a different computer.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -AddAppLayer -LayerId 3 -LayerVersion 1.0 -Server mirage.eucware.com

    Assign an application layer to the computer the script runs on.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -Migration -LayerId 1 -LayerVersion 5.0 -TargetDomain eucware.com -TargetOU "OU=Win7,OU=DEV,OU=Domain Clients,DC=eucware,DC=com" -Server mirage.eucware.com

    Start a Windows migration.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -Migration -LayerId 1 -LayerVersion 5.0 -TargetDomain eucware.com -TargetOU "OU=Win7,OU=DEV,OU=Domain Clients,DC=eucware,DC=com" -DownloadOnly -Server mirage.eucware.com

    Start download of the base layer used for a Windows migration.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -Migration -LayerId 1 -LayerVersion 5.0 -TargetDomain eucware.com -TargetOU "OU=Win7,OU=DEV,OU=Domain Clients,DC=eucware,DC=com" -TargetName MyNewComputerName -Server mirage.eucware.com

    Start a Windows migration during which the computer name will be changed to "MyNewComputerName".

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -EnforceLayers -RemoveUserApps -Server mirage.eucware.com
    
    Enforce all layers and also remove user installed applications.
        
  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -EnforceLayers -Server mirage.eucware.com
    
    Enforce all layers while preserving user installed applications.

  .EXAMPLE
    .\Invoke-RemoteMirageOperation.ps1 -Restore -TargetName MyRestoreTarget -Server mirage.eucware.com
    
    Restore the current computer (CVD) to the device "MyRestoreTarget"

  .NOTES
    NAME: Invoke-RemoteMirageOperation.ps1
    AUTHOR: Tim Arenz, VMware Global Inc, tarenz@vmware.com
    DISCLAIMER: No Warranty. This script is provided "as is" without warranty of any kind, either express or implied, including without limitation any implied warranties of condition, uninterrupted use, merchantability, fitness for a particular purpose, or non-infringement.

  .LINK
    http://www.vmware.com
    http://www.horizonflux.com

#>

[cmdletbinding(DefaultParameterSetName="none")]

# Get parameters
Param(
  # Get operation which should be invoked
  [Parameter(Mandatory=$True,ParameterSetName="AssignCVDPolicy")]
  [switch]$AssignCVDPolicy,
  [Parameter(Mandatory=$True,ParameterSetName="Centralize")]
  [switch]$Centralize,
  [Parameter(Mandatory=$True,ParameterSetName="BaseLayer")]
  [switch]$AssignBaseLayer,
  [Parameter(Mandatory=$True,ParameterSetName="AppLayer")]
  [switch]$AddAppLayer,
  [Parameter(Mandatory=$True,ParameterSetName="Provisioning")]
  [switch]$Provisioning,
  [Parameter(Mandatory=$True,ParameterSetName="Migration")]
  [switch]$Migration,
  [Parameter(Mandatory=$True,ParameterSetName="EnforceLayers")]
  [switch]$EnforceLayers,
  [Parameter(Mandatory=$True,ParameterSetName="Restore")]
  [switch]$Restore,
  
  # Additional parameters based on the operations
  [Parameter(Mandatory=$True,ParameterSetName="BaseLayer")]
  [Parameter(Mandatory=$True,ParameterSetName="AppLayer")]
  [Parameter(Mandatory=$True,ParameterSetName="Provisioning")]
  [Parameter(Mandatory=$True,ParameterSetName="Migration")]
  [Parameter(ParameterSetName="Centralize")]
  [string]$LayerId,
  [Parameter(Mandatory=$True,ParameterSetName="BaseLayer")]
  [Parameter(Mandatory=$True,ParameterSetName="AppLayer")]
  [Parameter(Mandatory=$True,ParameterSetName="Provisioning")]
  [Parameter(Mandatory=$True,ParameterSetName="Migration")]
  [Parameter(ParameterSetName="Centralize")]
  [string]$LayerVersion,
  [Parameter(Mandatory=$True,ParameterSetName="Provisioning")]
  [Parameter(Mandatory=$True,ParameterSetName="Migration")]
  [string]$TargetDomain,
  [Parameter(Mandatory=$True,ParameterSetName="Provisioning")]
  [Parameter(Mandatory=$True,ParameterSetName="Migration")]
  [string]$TargetOU,
  [Parameter(Mandatory=$True,ParameterSetName="Provisioning")]
  [Parameter(Mandatory=$True,ParameterSetName="Centralize")]
  [Parameter(Mandatory=$True,ParameterSetName="AssignCVDPolicy")]
  [string]$PolicyId,
  [Parameter(Mandatory=$True,ParameterSetName="Provisioning")]
  [Parameter(Mandatory=$True,ParameterSetName="Centralize")]
  [Parameter(Mandatory=$False,ParameterSetName="AssignCVDPolicy")]
  [string]$PolicyVersion,
  [Parameter(ParameterSetName="EnforceLayers")]
  [switch]$RemoveUserApps,
  [Parameter(ParameterSetName="Migration")]
  [switch]$DownloadOnly,
  [Parameter(Mandatory=$True,ParameterSetName="Restore")]
  [Parameter(ParameterSetName="Migration")]
  [Parameter(ParameterSetName="Provisioning")]
  [string]$TargetName,
  [string]$SourceName=$env:COMPUTERNAME,
  [string]$LogLevel="INFO",
  [Parameter(Mandatory=$True,HelpMessage="Enter the computer name or FQDN of the Mirage management server.")]
  [string]$Server,
  [string]$User,
  [string]$Domain,
  [string]$Password,
  [string]$LogFile = "$Env:ProgramFiles\Wanova\Mirage Service\Logs\Invoke-RemoteMirageOperation.log"
)


# Functions
# Write log function to write output to the host and also to the command line using one simple command
function Write-Log {
  Param(
    [Parameter(Mandatory=$True)]
    [string]$LogEntry,
	[string]$LogType="INFO"
  )
  
  $LogDate = Get-Date -format dd.MM.yyyy
  $LogTime = Get-Date -format HH:mm:ss:ff
  $LogContent = "[$LogDate][$LogTime][$LogType] $LogEntry"
  
  If ($LogLevel -ne "NONE") {
    Add-Content $LogFile -value "$LogContent"
    If ($LogType -eq "ERROR") {
	  Write-Host "$LogContent" -ForegroundColor Red
	} ElseIf ($LogType -eq "WARNING") {
	  Write-Host "$LogContent" -ForegroundColor Yellow
    } ElseIf ($LogType -eq "VERBOSE") {
      If ($LogLevel -eq "VERBOSE") {
        Write-Host "$LogContent" -ForegroundColor Yellow
      }
	} Else {
	  Write-Host "$LogContent" -ForegroundColor Green
	}
  }
}

# Function to invoke the Mirage operation on a remote server.
# The remote server needs to be the Mirage management server.
# To enable PowerShell remoting run Enable-PSRemoting on the remote server.
function Invoke-MirageCommand {
  Param(
    [Parameter(Mandatory=$True)]
    [string]$Command,
    [string]$Server = "localhost"
  )

  $Result = Invoke-Command -Session $RemoteSession -ArgumentList $Command, $Server -ScriptBlock {
    Param ($Command,$Server)
    $MirageCli = "$env:ProgramFiles\Wanova\Mirage Management Server\Wanova.Server.Cli.exe"
    $Randomizer = Get-Random
    $DateNow = Get-Date -format yyyyMMdd
    $TimeNow = Get-Date -format HHmmss
    $ScriptFile = New-Item -path $env:TEMP -name "$DateNow-$TimeNow-MirageServerJob-$Randomizer.vmj" -ItemType "file"
    Add-Content -Path $ScriptFile -Value $Command -Force
    $MirageCliOuput = & $MirageCli $Server -s $ScriptFile
    Remove-Item -Path $ScriptFile -Force
    Return $MirageCliOuput
  }

  Return $Result

}

function Get-DeviceId {
#getDeviceId <Machine name> - get deviceId from machine name
Param(
  [Parameter(Mandatory=$True)]
  [string]$MachineName
)
  $CommandOutput = Invoke-MirageCommand -Command "getDeviceId $MachineName"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  If ($CommandOutput.count -eq "3") {
    Return $CommandOutput[2]
  } Else {
    Write-Log -LogEntry "Device id of $MachineName not found!" -LogType "ERROR"
    Return 1
  }
}

function Get-CvdId {
#getCvdId <Machine name> - get CvdId from machine name
Param(
  [Parameter(Mandatory=$True)]
  [string]$MachineName
)
  $CommandOutput = Invoke-MirageCommand -Command "getCvdId $MachineName"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  If ($CommandOutput.count -eq "3") {
    Return $CommandOutput[2]
  } Else {
    Write-Log -LogEntry "CVD id for $MachineName not found!" -LogType "ERROR"
    Return 1
  }
}

If (!(Test-Path ($LogFile | Split-Path))) {
  Write-Error "Log file location ($($LogFile | Split-Path)) not accessible!"
  Exit 1
}

If ($PSCmdlet.ParameterSetName -eq "none") {
  Write-Log -LogEntry "No operation (Centralize, AssignBaseLayer, etc.) specified!" -LogType "WARNING"
  Write-Log -LogEntry "Run Get-Help $MyInvocation.MyCommand for usage information." -LogType "WARNING"
  Exit 1
}

# Connecting to remote server
Try {
  Write-Verbose "Checking if alternate credentials were provided."
  # If no user is provided connection is established using current user
  If (!$User) {
    Write-Log -LogEntry "Tying to connect to server $Server." -LogType "VERBOSE"
    $RemoteSession = New-PSSession -ComputerName $Server -ErrorAction Stop
   Write-Log -LogEntry "Connected to server $Server."
  } Else {
  # If alternative user is provided it will be checked if the required parameters (domain and password) are specified.
  # If not the script will exist. If they are provided connection will be established using the alternative credentials.
    If (!$Domain) {
       Write-Log -LogEntry "Domain not specified!" -LogType "ERROR"
       Exit 1
    } ElseIf (!$Password) {
       Write-Log -LogEntry "Password not specified!" -LogType "ERROR"
       Exit 1
    } Else {
      Write-Log -LogEntry "Creating PowerShell compatible credentials." -LogType "VERBOSE"
      # Convert plain text password to a PowerShell secure string
      $Pwd = ConvertTo-SecureString -AsPlainText -Force -String $Password
      # Create PowerShell credentials
      $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$Domain\$User",$Pwd
      Write-Log -LogEntry "Tying to connect to server $Server." -LogType "VERBOSE"
      $RemoteSession = New-PSSession -ComputerName $Server -ErrorAction Stop -Credential $Cred
      Write-Log -LogEntry "Connected to server $Server."
    }
  }
}
Catch {
  Write-Log -LogEntry "Could not connect to $Server!" -LogType "ERROR"
  Exit 1
}

# Execute when parameter AssignCVDPolicy is set 
If ($AssignCVDPolicy) {
  # Get device id based on the SourceName variable
  $CvdId = Get-CvdId $SourceName
  # Create Mirage CLI specific command
  $CommandInput = "assignUploadPolicy $CvdId $PolicyId"

  # If policy version is specified add policy version to CLI command
  # If no policy version is specified Mirage uses the latest version
  If ($PolicyVersion) {
    $CommandInput = $CommandInput + " " + $PolicyVersion
  }

  # Invoke Mirage command and write output to variable
  $CommandOutput = Invoke-MirageCommand -Command "$CommandInput"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"

  # If output has 3 lines and the third line include the string "Assign policy $PolicyId to CVD $CvdId" asume that there was no error.
  If ($CommandOutput.count -eq "3" -and ($CommandOutput[2] -match "Assign policy $PolicyId to CVD $CvdId")) {
    Write-Log -LogEntry "CVD policy successfully assigned."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
    # If more or less then three lines are returned and the string "Assign policy $PolicyId to CVD $CvdId" is not found asume that terhe is an error.
    Write-Log -LogEntry "CVD policy assignment failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}

# Execute when parameter centralize is set 
If ($Centralize) {
  # Get device id based on the SourceName variable
  $DeviceId = Get-DeviceId $SourceName
  # Create Mirage CLI specific command
  $CommandInput = "assignDeviceNewCvd $DeviceId $PolicyId"

  # If policy version is specified add policy version to CLI command
  # If no policy version is specified Mirage uses the latest version
  If ($PolicyVersion) {
    $CommandInput = $CommandInput + " " + $PolicyVersion
  }

  # If layer id specified add layer id and version to CLI command
  If ($LayerId) {
    $CommandInput = $CommandInput + " " + "$LayerId $LayerVersion"
  }

  # Invoke Mirage command and write output to variable
  $CommandOutput = Invoke-MirageCommand -Command "$CommandInput"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"

  # If two lines are returned we asume that there was no error.
  If ($CommandOutput.count -eq "2") {
    Write-Log -LogEntry "Centralization succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
  # If more or less then two lines are returned we asume that an error occured.
    Write-Log -LogEntry "Centralization failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}

# Execute when parameter AssignBaseLayer is set
If ($AssignBaseLayer) {
  # Get CvdId for the device based on the SourceName variable
  $CvdId = Get-CvdId $SourceName

  # Invoke Mirage command with Mirage CLI specific command and write output to variable
  $CommandOutput = Invoke-MirageCommand -Command "assignBaseLayer $CvdId $LayerId $LayerVersion"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  # If output has 3 lines and the third line include the string "BI assignment done" asume that there was no error.
  If ($CommandOutput.count -eq "3" -and ($CommandOutput[2] -match "BI assignment done")) {
    Write-Log -LogEntry "Base layer assignment succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
    # If more or less then three lines are returned and the string "BI assignment done" is not found asume that terhe is an error.
    Write-Log -LogEntry "Base layer assignment failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}

# Execute when parameter AddAppLayer is set
If ($AddAppLayer) {
  # Get CvdId for the device based on the SourceName variable
  $CvdId = Get-CvdId $SourceName

  # Invoke Mirage command with Mirage CLI specific command and write output to variable
  $CommandOutput = Invoke-MirageCommand -Command "addAppLayers $CvdId $LayerId $LayerVersion"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  # If output has 3 lines and the third line include the string "App layer assignment done" asume that there was no error.
  If ($CommandOutput.count -eq "3" -and ($CommandOutput[2] -match  "App layer assignment done")) {
    Write-Log -LogEntry "App layer assignment succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
    # If more or less then three lines are returned and the string "App layer assignment done" is not found asume that there is an error.
    Write-Log -LogEntry "App layer assignment failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}

# Execute when parameter Provisioning is set
If ($Provisioning) {
  # Get device id based on the SourceName variable
  $DeviceId = Get-DeviceId $SourceName

  # Create Mirage CLI specific command
  # -1 chooes volume automatically. If specific volume should be used please replace -1 by the volume id.
  $CommandInput = "provisioning $DeviceId $PolicyId $PolicyVersion -1 $LayerId $LayerVersion"

  # If TargetName is set use new name instead of current name (SourceName)
  If ($TargetName) {
    $CommandInput = $CommandInput + " " + "$TargetName $TargetDomain `"$TargetOU`""
  } Else {
    $CommandInput = $CommandInput + " " + "$SourceName $TargetDomain `"$TargetOU`""
  }

  # Invoke Mirage command with Mirage CLI specific command and write output to variable
  $CommandOutput = Invoke-MirageCommand -Command "$CommandInput"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  # If output has 3 lines and the third line include the string "name=BiProvisioning, status=In Progress, status-code=Running" asume that there was no error.
  If ($CommandOutput.count -eq "3" -and ($CommandOutput[2] -match "name=BiProvisioning, status=In Progress, status-code=Running")) {
    Write-Log -LogEntry "Provisioning succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
  # If more or less then three lines are returned and the string "name=BiProvisioning, status=In Progress, status-code=Running" is not found asume that there is an error.
    Write-Log -LogEntry "Provisioning failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}

# Execute when parameter Provisioning is set
If ($Migration) {
  # Get Cvd id based on the SourceName variable
  $CvdId = Get-CvdId $SourceName

  # Create Mirage CLI specific command
  $CommandInput = "migrate $CvdId $LayerId $LayerVersion"

  #If DownloadOnly parameter is set set download only option to true else to false.  
  If ($DownloadOnly) {
    $CommandInput = $CommandInput + " true"
  } Else {
    $CommandInput = $CommandInput + " false"
  }

  # If TargetName is set use new name instead of current name (SourceName)
  If ($TargetName) {
    $CommandInput = $CommandInput + " " + "$TargetName $TargetDomain `"$TargetOU`""
  } Else {
    $CommandInput = $CommandInput + " " + "$SourceName $TargetDomain `"$TargetOU`""
  }
  
  # Invoke Mirage command with Mirage CLI specific command and write output to variable  
  $CommandOutput = Invoke-MirageCommand -Command "$CommandInput"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  # If output has 3 lines and the third line include the string "name=Migration, status=In Progress, status-code=Running" asume that there was no error.
  If ($CommandOutput.count -eq "3" -and ($CommandOutput[2] -match "name=Migration, status=In Progress, status-code=Running")) {
    Write-Log -LogEntry "Migration succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } ElseIf ($CommandOutput.count -eq "3" -and ($CommandOutput[2] -match "name=MigrateDownloadOnly, status=In Progress, status-code=Running")) {
  # If output has 3 lines and the third line include the string "name=MigrateDownloadOnly, status=In Progress, status-code=Running" asume that there was no error.
    Write-Log -LogEntry "Migration download succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
  # If more or less then three lines are returned and the strings specified above are not found asume that there is an error.
    Write-Log -LogEntry "Migration failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}

# Execute when EnforceLayers is set
If ($EnforceLayers) {
  # Get Cvd id based on the SourceName variable
  $CvdId = Get-CvdId $SourceName

  # Create Mirage CLI specific command
  $CommandInput = "enforceLayers $CvdId"

  # If RemoveUserApps is set add mCleanup to CLI command
  If ($RemoveUserApps) {
    $CommandInput = $CommandInput + " mCleanUp"
  }
  
  # Invoke Mirage command with Mirage CLI specific command and write output to variable   
  $CommandOutput = Invoke-MirageCommand -Command "$CommandInput"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  # If two lines are returned we asume that there was no error.
  If ($CommandOutput.count -eq "2") {
    Write-Log -LogEntry "Enforce layers succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
  # If more or less then two lines are returned we asume that an error occured.
    Write-Log -LogEntry "Enforce layers failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}

#Execute when Restore is set
If ($Restore) {
  # Get Cvd id based on the SourceName variable
  $CvdId = Get-CvdId $SourceName
  # Get device id based on the TargetName variable
  $DeviceId = Get-DeviceId $TargetName

  # Invoke Mirage command with Mirage CLI specific command and write output to variable
  $CommandOutput = Invoke-MirageCommand -Command "assignDeviceToexistingCvd $DeviceId $CvdId"
  Write-Log -LogEntry "$CommandOutput" -LogType "VERBOSE"
  # If output has 3 lines and the third line include the string "name=AssignDevice, status=Starting, status-code=Running" asume that there was no error.
  If ($CommandOutput.count -eq "3" -and ($CommandOutput[2] -match "name=AssignDevice, status=Starting, status-code=Running")) {
    Write-Log -LogEntry "Restore succesfully triggered."
    Remove-PSSession -Session $RemoteSession
    Exit 0
  } Else {
  # If more or less then three lines are returned and the string "name=AssignDevice, status=Starting, status-code=Running" is not found asume that there is an error.
    Write-Log -LogEntry "Restore failed!" -LogType "ERROR"
    Remove-PSSession -Session $RemoteSession
    Exit 1
  }
}