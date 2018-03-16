. $PSScriptRoot\..\functions\helpers.ps1

$phpVersion = $null

if ($args -and ($args[0] -match '\-[0-9.]')) {
	$phpVersion = $args[0].Substring(1)
	$args = $args[1 .. $args.count]
}

$phpPath = Find-PHP -version $phpVersion

if (! $phpPath) {
	if ($phpVersion) {
		throw [System.IO.FileNotFoundException] "[mphp] No PHP $phpVersion executable found."
	} else {
		throw [System.IO.FileNotFoundException] "[mphp] No PHP executable found."
	}
}

& $phpPath @args