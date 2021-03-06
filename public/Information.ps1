Function Get-bwsHelp {
	<#
	.SYNOPSIS
	List commands available in the brshWinServices Module

	.DESCRIPTION
	List all available commands in this module

	.EXAMPLE
	Get-wsHelp
	#>
	Write-Host ""
	Write-Host "Getting available functions..." -ForegroundColor Yellow

	$all = @()
	$list = Get-Command -Type function -Module "brshWinServices" | Where-Object { $_.Name -in $script:ShowHelp}
	$list | ForEach-Object {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
			$RetHelp = Get-Help $_.Name -ShowWindow:$false -ErrorAction SilentlyContinue
        } else {
            $RetHelp = Get-Help $_.Name -ErrorAction SilentlyContinue
        }
		if ($RetHelp.Description) {
			$Infohash = @{
				Command     = $_.Name
				Description = $RetHelp.Synopsis
			}
			$out = New-Object -TypeName psobject -Property $InfoHash
			$all += $out
		}
	}
	$all | Select-Object Command, Description | format-table -Wrap -AutoSize | Out-String | Write-Host
}
