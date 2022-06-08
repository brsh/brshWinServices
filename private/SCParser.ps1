function Format-SCOutput {
    param (
        [string[]] $SCText
    )
    [string] $ResultFull = $SCText | Select-String -SimpleMatch '[SC]'
    [string] $Result = if ($ResultFull -match 'SUCCESS') { 'Success' } else { 'Error' }
    [string] $ResultCode = $ResultFull -replace '[^\d+]', ''
    [string] $ResultText = (Get-bwsSCResultCode -Code $ResultCode).Text
    [int] $SecondsToReset = if ($SCText -match 'RESET_Period') {
        ($SCText | Select-String 'RESET_PERIOD') -replace '[^\d+]', ''
    } else {
        -1
    }
    [string] $FailureAction1, [string] $FailureAction2, [string] $FailureAction3 = ((([string] ($SCText | Select-String 'FAILURE_ACTIONS' -Context 0, 2)) -replace '(FAILURE_ACTIONS|:|>|\s--)', '' -replace 'milliseconds.', 'ms') -replace '(?<=\d)(?=(\d{3})+\b)', ',' -split '\n').Trim()
            

    [pscustomobject] [ordered] @{
        Result          = $Result
        ResultCode      = $ResultCode
        ResultText      = $ResultText
        SecondsToReset  = $SecondsToReset
        FailureAction_1 = $FailureAction1
        FailureAction_2 = $FailureAction2
        FailureAction_3 = $FailureAction3
    }
}