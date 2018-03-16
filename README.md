# MPHP

Multi-version PHP is a Windows utility to use one executable to run different versions of PHP CLI.

## Installation

> MPHP is installed by default to the `%SYSTEMDRIVE%\tools\mphp` directory

Download [install.ps1](https://github.com/uiii/mphp/blob/master/install.ps1) script and run it in the PowerShell as administrator.

Or run this command in `Cmd.exe` as administrator:
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/uiii/mphp/master/install.ps1'))"
```

You also need to install at least one versions of PHP.

## Usage

Use MPHP the same way as you would use PHP CLI executable.
You can specify the PHP version as the first argument `-<version>`.

> E.g. `php -5 -i` will run *PHP 5.\** executable with argument `-i`.

MPHP will find PHP's executable with latest matching version.

> E.g. version argument `5.6` will look for latest version matching *5.6.\**.

If you ommit the version argument, it will run the latest PHP version found.

`version` argument could be any version number, e.g. `5`, `5.6.32`, ...

## Paths

MPHP will find executable of the specified PHP version using system `PATH` environment variable. 
So you have to add all paths to all installed PHP's version to `PATH`.

## Troubleshooting

### Switching PHP versions is not working (-v parameter)
Run `where php` to make sure the MPHP's executable (`%SYSTEMDRIVE%\tools\mphp\bin\php.bat`) is the first. If not, move the `%SYSTEMDRIVE%\tools\mphp\bin` path in system `PATH` environment variable before any other path to `php` executable.