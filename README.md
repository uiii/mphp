# MPHP

Multi-version PHP is a Windows utility to use one executable to run different versions of PHP CLI.

## Installation

> MPHP is installed only for the **current user** in the `%LOCALAPPDATA%\mphp` directory

Download [install.ps1](https://github.com/uiii/mphp/blob/master/install.ps1) script and run it in the PowerShell.

Or run this command in `Cmd.exe`:
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/uiii/mphp/master/install.ps1'))"
```

## Usage

> Install some PHP versions first

Use MPHP the same way as you would use PHP CLI executable.
You can specify the PHP version as the first argument `-<version>`.
E.g. `mphp -5 -v` will run PHP 5 executable with argument `-v`.
If you ommit the PHP version argument, it will run the highest previously found PHP version.

`version` argument could be any version number, e.g. `5`, `5.6.32`, ...

## Paths

MPHP will try to find (search all hard drives) executable of the specified PHP version.
If you want to specify the path manually, put it in the file `%LOCALAPPDATA%\mphp\.cache\paths` in format `<php-version>|<php-installation-path>`.

For e.g.
```
5|C:\tools\php56
7|C:\tools\php71
```