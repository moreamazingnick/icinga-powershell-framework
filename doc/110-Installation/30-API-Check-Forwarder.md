# API Check Forwarder

With Icinga for Windows v1.6.0 we introduced a new feature, allowing to forward executed checks to an internal REST-Api. This will move the check execution from the current PowerShell scope to an internal REST-Api daemon and endpoint and run the command with all provided arguments there.

This will reduce the performance impact on the CPU as well as lower the loading time of the Icinga PowerShell Framework, as only very basic core functionality is required for this.

## Requirements

To use this feature, you wil require the following

* Icinga Agent is certificates installed
* Icinga for Windows v1.6.0 installed
* [Icinga for Windows Service installed](https://icinga.com/docs/icinga-for-windows/latest/doc/service/01-Install-Service/)
* Icinga for Windows v1.4.0+ CheckCommand configuration applied (**Important:** Update your entire Windows environment to v1.4.0+ before updating the Icinga configuration!)

## Installation with IMC

In order to install the REST-Api feature, you can simply enable it by using the IMC. On new installations with the IMC, the feature is enabled by default.

* At first, run `icinga` in your PowerShell to open the IMC
* Navigate to `Settings`
* Navigate to `Icinga for Windows Features`
* Toggle the setting `Api-Check Forwarder` by using the menu index entry (besides the feature is mentioned if it is `Enabled` or `Disabled`)

Please note that you will require to have the [Icinga for Windows Service](https://icinga.com/docs/icinga-for-windows/latest/doc/service/01-Install-Service/) already installed. The menu entry will only ensure, that the entire configuration is made and that check commands are enabled as commands.

## Manual Installation and Configuration

### Install Icinga for Windows Service

To make this entire construct work, we will require to install the Icinga for Windows service. You can read more about this on the [background daemon page](05-Background-Daemons.md).

### Register Background Daemon

To access our REST-Api we have to register it as background daemon. We can do this by running the command:

```powershell
Register-IcingaBackgroundDaemon -Command 'Start-IcingaWindowsRESTApi';
```

By default, it will start listening on Port `5668` on `localhost` and use the Icinga Agents certificates for TLS encrypted communication. As long as the Windows firewall is not allowing access to this port, external communication is not possible.

To modify any REST-Api arguments, please follow the [REST-Api installation guide](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/02-Installation/#daemon-registration).

### Whitelist Check Commands

By default the Api-Checks module is rejecting every single request to execute commands, as long as they are not whitelisted.

You can whitelist all check commands with an wildcard by using `Invoke-IcingaCheck*` for the `apichecks` module.

```powershell
Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'apichecks';
```

Of course, you can also whitelist every single command without wildcard for more security.

### Blacklist Check Commands

If you do not want to execute certain checks, but keep the previous wildcard whitelist, you can blacklist a single command (or use wildcard to match multiple):

```powershell
Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheckCertificate' -Endpoint 'apichecks' -Blacklist;
```

Blacklists are checked prior to whitelist. If you are running wildcard filters for both, whitelist and blacklist, blacklist entries will win first and block the execution if they match the filter.

### Enable Api Check Feature

Now as we configured our host with all required components, we simply require to enable the api checks feature:

```powershell
Enable-IcingaFrameworkApiChecks;
```

Last but not least restart the Icinga for Windows service:

```powershell
Restart-IcingaWindowsService;
```

As long as the feature is enabled, the Icinga for Windows service is running, the REST-Api daemon is registered and both modules, [icinga-powershell-restapi](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/01-Introduction/) and [icinga-powershell-apichecks](https://icinga.com/docs/icinga-for-windows/doc/icinga_for_windows_v1.6.0/apichecks/doc/01-Introduction/) are installed, checks will be forwarded to the REST-Api and executed, if whitelisted.

### Disable Api Check Feature

You can disable the Api check feature anytime by running

```powershell
Disable-IcingaFrameworkApiChecks;
```

Once disabled checks will be executed within the local, current shell and not being forwarded to the API.

### Summary

For quick installation, here the list of commands to get everything running:

```powershell
Register-IcingaBackgroundDaemon -Command 'Start-IcingaWindowsRESTApi';
Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'apichecks';

Restart-IcingaWindowsService;

Enable-IcingaFrameworkApiChecks;
```

## EventLog Errors

In case a check could not be executed by using this experimental feature, either because of timeouts or other issues, they are added with `EventId 1553` inside the EventLog for `Icinga for Windows`. A description on why the check could not be executed is added within the event output.
