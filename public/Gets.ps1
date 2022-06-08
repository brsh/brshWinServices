function Get-bwsSCResultCode {
    <#
    .SYNOPSIS
    Translates sc.exe error codes to text

    .DESCRIPTION
    If you use sc.exe for service control related type things, you will get an error/result
    code when you do. This function merely translates said code to human readable text.

    Comes from https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--1000-1299-

    .PARAMETER Code
    The code number to translate

    .EXAMPLE
    Get-bwsSCResultCode -code 1053

    Returns the Service_Request_Timeout error from the code

    .LINK
    https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--1000-1299-
    #>
    param (
        [int] $Code = 0
    )
    #
    $SCResultCodes = @(
        [pscustomobject] [ordered] @{
            Code        = 2
            Text        = 'No_Error'
            Description = 'This is not actually an error or return code :)'
        }
        [pscustomobject] [ordered] @{
            Code        = 1051
            Text        = 'Dependent_Services_Running'
            Description = 'A stop control has been sent to a service that other running services are dependent on.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1052
            Text        = 'Invalid_Service_Control'
            Description = 'The requested control is not valid for this service.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1053
            Text        = 'Service_Request_Timeout'
            Description = 'The service did not respond to the start or control request in a timely fashion.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1054
            Text        = 'Service_No_Thread'
            Description = 'A thread could not be created for the service.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1055
            Text        = 'Service_Database_Locked'
            Description = 'The service database is locked.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1056
            Text        = 'Service_Already_Running'
            Description = 'An instance of the service is already running.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1057
            Text        = 'Invalid_Service_Account'
            Description = 'The account name is invalid or does not exist, or the password is invalid for the account name specified.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1058
            Text        = 'Service_Disabled'
            Description = 'The service cannot be started, either because it is disabled or because it has no enabled devices associated with it.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1059
            Text        = 'Circular_Dependency'
            Description = 'Circular service dependency was specified.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1060
            Text        = 'Service_Does_Not_Exist'
            Description = 'The specified service does not exist as an installed service.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1061
            Text        = 'Service_Cannot_Accept_Ctrl'
            Description = 'The service cannot accept control messages at this time.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1062
            Text        = 'Service_Not_Active'
            Description = 'The service has not been started.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1063
            Text        = 'Failed_Service_Controller_Connect'
            Description = 'The service process could not connect to the service controller.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1064
            Text        = 'Exception_In_Service'
            Description = 'An exception occurred in the service when handling the control request.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1066
            Text        = 'Service_Specific_Error'
            Description = 'The service has returned a service-specific error code.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1067
            Text        = 'Process_Aborted'
            Description = 'The process terminated unexpectedly.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1068
            Text        = 'Service_Dependency_Fail'
            Description = 'The dependency service or group failed to start.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1069
            Text        = 'Service_Logon_Failed'
            Description = 'The service did not start due to a logon failure.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1070
            Text        = 'Service_Start_Hang'
            Description = 'After starting, the service hung in a start-pending state.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1071
            Text        = 'Invalid_Service_Lock'
            Description = 'The specified service database lock is invalid.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1072
            Text        = 'Service_Marked_For_Delete'
            Description = 'The specified service has been marked for deletion.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1073
            Text        = 'Service_Exists'
            Description = 'The specified service already exists.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1074
            Text        = 'Already_Running_LKG'
            Description = 'The system is currently running with the last-known-good configuration.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1075
            Text        = 'Service_Dependency_Deleted'
            Description = 'The dependency service does not exist or has been marked for deletion.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1078
            Text        = 'Duplicate_Service_Name'
            Description = 'The name is already in use as either a service name or a service display name.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1079
            Text        = 'Different_Service_Account'
            Description = 'The account specified for this service is different from the account specified for other services running in the same process.'
        }
        [pscustomobject] [ordered] @{
            Code        = 1639
            Text        = 'Invalid_Command_Line'
            Description = 'Invalid command line argument. Consult the Windows Installer SDK for detailed command line help.'
        }
    )
    if ($Code -gt 0) {
        $SCResultCodes | Where-Object Code -EQ $Code
    } else {
        $SCResultCodes
    }
}

function Get-bwsServiceAutoRecovery {
    <#
    .SYNOPSIS
    Wraps sc.exe output to get the Recovery options for a Windows Service

    .DESCRIPTION
    If a Windows service fails for any reason, the OS _can_ restart the service, restart the system
    (or, really, a bunch of other options if you're willing to script it). However, the default is to
    just let the service die with no recovery.

    If you _want_ the service to restart automatically (which, most times most people will), there
    are a couple ways to get the recovery options. This is one of them.

    This function leverages sc.exe to _get_ the current recovery options for a Service - you can
    specify either the DisplayName or the "real" name of the service

    .PARAMETER ServiceDisplayName
    The Display Name of the service - this one might have spaces, so use quotes if so

    .PARAMETER ServiceName
    The potentially oddball "real" name of the service

    .PARAMETER Server
    The system to connect to

    .EXAMPLE
    Get-bwsServiceAutoRecover -Server ThatOne -ServiceDisplayName 'The Main Service'

    Returns the recovery options for "The Main Service" on the system named ThatOne

    .EXAMPLE
    Get-bwsServiceAutoRecover -Server ThatOne -ServiceName mainsvc

    Returns the recovery options for "mainsvc" (which might be "The Main Service") on the system named ThatOne
    #>
    [CmdLetBinding(DefaultParameterSetName = 'Display')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Display')]
        [string] $ServiceDisplayName,
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')]
        [string] $ServiceName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true, Position = 1)]
        [string[]] $Server = $env:COMPUTERNAME
    )
    BEGIN {
        [string] $sc = (Get-Command sc.exe -ErrorAction SilentlyContinue).Source
        if ($sc.Trim().Length -eq 0) {
            Throw "sc.exe not found in path"
        } else {
            Write-Verbose "Found sc.exe: $sc"
        }

        if ($PSCmdlet.ParameterSetName -eq 'Name') {
            $Splat = @{
                ServiceName = "*${ServiceName}*"
            }
            $ServiceToFind = "*${ServiceName}*"
        } else {
            $Splat = @{
                ServiceDisplayName = "*${ServiceDisplayName}*"
            }
            $ServiceToFind = "*${ServiceDisplayName}*"
        }
    }

    PROCESS {
        foreach ($Computer in $Server) {
            Write-Verbose "Attempting to Get Recovery Options on $Computer"
            [string] $ServerPath = "\\$Computer"
            $Splat.Computer = $Computer
            [string[]] $Services = Get-bwsServices @Splat
            if ($Null -ne $Services) {
                foreach ($Service in $Services) {
                    # https://technet.microsoft.com/en-us/library/cc742019.aspx
                    Write-Verbose "sc.exe $ServerPath qfailure $Service"
                    $Return = sc.exe $ServerPath qfailure $Service
                    Write-Verbose ($Return -join "`r`n")
                    $Parsed = Format-SCOutput -SCText $Return
                }
            } else {
                $Service = $ServiceToFind
                $Parsed = @{
                    Result          = 'Error'
                    ResultCode      = 1060
                    ResultText      = 'Service_Does_Not_Exist'
                    SecondsToReset  = -1
                    FailureAction_1 = 'n/a'
                    FailureAction_2 = 'n/a'
                    FailureAction_3 = 'n/a'
                    SCResponse      = $Return -join "`r`n"
                }
            }
            [pscustomobject] [ordered] @{
                PSTypeName      = 'brshWS.RetryInfo'
                Computer        = $Computer
                Service         = $Service
                Result          = $Parsed.Result
                ResultCode      = $Parsed.ResultCode
                ResultText      = $Parsed.ResultText
                SecondsToReset  = [int] $Parsed.SecondsToReset
                FailureAction_1 = $Parsed.FailureAction_1
                FailureAction_2 = $Parsed.FailureAction_2
                FailureAction_3 = $Parsed.FailureAction_3
                SCResponse      = $Return -join "`r`n"
            }
        }
    }

    END { }
}
