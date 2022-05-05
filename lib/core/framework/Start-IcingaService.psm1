<#
.SYNOPSIS
    Wrapper for Start-Service which catches errors and prints proper output messages
.DESCRIPTION
    Starts a service if it is installed and prints console messages if a start
    was triggered or the service is not installed
.FUNCTIONALITY
    Wrapper for Start-Service which catches errors and prints proper output messages
.EXAMPLE
    PS>Start-IcingaService -Service 'icinga2';
.PARAMETER Service
    The name of the service to be started
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Start-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice -Message 'Starting service "{0}"' -Objects $Service;

        & powershell.exe -Command {
            $Service = $args[0];
            try {
                Start-Service "$Service" -ErrorAction Stop;
                Start-Sleep -Seconds 2;
                Optimize-IcingaForWindowsMemory;
            } catch {
                Write-IcingaConsoleError -Message 'Failed to start service "{0}". Error: {1}' -Objects $Service, $_.Exception.Message;
            }
        } -Args $Service;
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }

    Optimize-IcingaForWindowsMemory;
}
