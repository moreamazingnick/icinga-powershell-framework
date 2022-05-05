function Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Advanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the path to your ca.crt file. This can be a local, network share or web address:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'To sign certificates locally you can copy the Icinga CA master "ca.crt" file (normally located at "/var/lib/icinga2/ca") to a location you can access from this host. Enter the full path on where you stored the "ca.crt" file. You can provide a local path "C:\users\public\ca.crt", a network share "\\share.example.com\icinga\ca.crt" or a web address "https://example.com/icinga/ca.crt"';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # By default, we are never prompt to enter the CA target path, unless we are connecting
    # from Parent->Agent, which is option 1 von IfW-Connection
    # In case we run this configuration, we are forwarded from that menu to here and require
    # to enter the hostname in addition
    if ((Test-IcingaForWindowsManagementConsoleContinue) -And $JumpToSummary -eq $FALSE) {
        $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerMenuSelectHostname';
    }
}

Set-Alias -Name 'IfW-CAFile' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
