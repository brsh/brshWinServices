function Get-bwsServices {
    [CmdLetBinding(DefaultParameterSetName = 'Display')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Display')]
        [string] $ServiceDisplayName,
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')]
        [string] $ServiceName,
        [string] $Computer = ''
    )
    if ($PSCmdlet.ParameterSetName -eq 'Name') {
        $Splat = @{
            Name = "*${ServiceName}*"
        }
        $ServiceToFind = "*${ServiceName}*"
    } else {
        $Splat = @{
            DisplayName = "*${ServiceDisplayName}*"
        }
        $ServiceToFind = "*${ServiceDisplayName}*"
    }

    $Splat.ComputerName = $Computer

    $Services = (Get-Service @Splat).Name
    if ($null -eq $Services) {
        Write-Verbose "$ServiceToFind Not Found on $Computer"
    } else {
        Write-Verbose "On $Computer, Found services:"
        $Services | ForEach-Object { Write-Verbose "  $_" }
    }
    $Services
}