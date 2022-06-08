function Set-bwsServiceAutoRecovery {
    <#
    .SYNOPSIS
    Uses sc.exe to set the Recovery options for a Windows Service

    .DESCRIPTION
    If a Windows service fails for any reason, the OS _can_ restart the service, restart the system
    (or, really, a bunch of other options if you're willing to script it). However, the default is to
    just let the service die with no recovery.

    If you _want_ the service to restart automatically (which, most times most people will), there
    are a couple ways to set the recovery options. This is one of them.

    This function leverages sc.exe to set the current recovery options to restart a Service - you can
    specify either the DisplayName or the "real" name of the service.

    Yes, you can do a bunch more with Recover options, but this is version 1 and restart was most
    important at this time.

    .PARAMETER ServiceDisplayName
    The Display Name of the service - this one might have spaces, so use quotes if so

    .PARAMETER ServiceName
    The potentially oddball "real" name of the service

    .PARAMETER Server
    The system to connect to

    .PARAMETER Time1
    How long (ms) to wait before trying to restart the service the 1st time (default = 30000ms)

    .PARAMETER Time2
    How long (ms) to wait before trying to restart the service the 2nd time (default = 30000ms)

    .PARAMETER Time3
    How long (ms) to wait before trying to restart the service all the subsequent times (default = 30000ms)

    .PARAMETER ResetCounter
    How long (s) before the OS resets the counter for the "first" time (default = 3600s)

    .EXAMPLE
    Set-bwsServiceAutoRecover -Server ThatOne -ServiceDisplayName 'The Main Service'

    Sets the recovery options for "The Main Service" on the system named ThatOne to the defaults

    .EXAMPLE
    Get-bwsServiceAutoRecover -Server ThatOne -ServiceName mainsvc -Time1 60000 -Time2 120000 -Time3 360000 -ResetCounter 6200

    Sets the recovery options for "mainsvc" (which might be "The Main Service") on the system named ThatOne to increasing delay values
    #>
    [CmdLetBinding(DefaultParameterSetName = 'Display')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Display')]
        [string] $ServiceDisplayName,
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')]
        [string] $ServiceName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true, Position = 1)]
        [string[]] $Server = $env:COMPUTERNAME,
        [Parameter(Mandatory = $false, Position = 2)]
        [int] $Time1 = 30000, # in miliseconds
        [Parameter(Mandatory = $false, Position = 3)]
        [int] $Time2 = 30000, # in miliseconds
        [Parameter(Mandatory = $false, Position = 4)]
        [int] $Time3 = 30000, # in miliseconds
        [Parameter(Mandatory = $false, Position = 5)]
        [int] $ResetCounter = 3600 # in seconds
    )
    BEGIN {
        [string] $sc = (Get-Command sc.exe -ErrorAction SilentlyContinue).Source
        if ($sc.Trim().Length -eq 0) {
            Throw "sc.exe not found in path"
        } else {
            Write-Verbose "Found sc.exe: $sc"
        }

        [string] $Action = "restart/$Time1/restart/$Time2/restart/$Time3"
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
            Write-Verbose "Attempting to Set Recovery Options on $Computer"
            [string] $ServerPath = "\\$Computer"
            $Splat.Computer = $Computer
            [string[]] $Services = Get-bwsServices @Splat

            if ($Null -ne $Services) {
                foreach ($Service in $Services) {
                    # https://technet.microsoft.com/en-us/library/cc742019.aspx
                    Write-Verbose "sc.exe $ServerPath failure $Service actions= $Action reset= $ResetCounter"
                    $Return = sc.exe $ServerPath failure $Service actions= $Action reset= $ResetCounter
                    Write-Verbose ($Return -join "`r`n")
                    $Parsed = Format-SCOutput -SCText $Return

                    if ($Parsed.Result -match 'Success') {
                        Get-bwsServiceAutoRecovery -ServiceName $Service -Server $Computer
                    } else {
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
            } else {
                [pscustomobject] [ordered] @{
                    PSTypeName      = 'brshWS.RetryInfo'
                    Computer        = $Computer
                    Service         = $ServiceToFind
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
        }

    }

    END { }
}
