. $PSScriptRoot\..\functions\helpers.ps1

if (-Not (Test-Path (Join-Path $cacheDir 'paths'))) {
	# cache not set, find all installed PHP versions
	Find-PHP -version '7' | Out-Null
	Find-PHP -version '5' | Out-Null
}

$phpVersion = $null

if ($args -and ($args[0] -match '\-[0-9.]')) {
	$phpVersion = $args[0].Substring(1)
	$args = $args[1 .. $args.count]
}

$phpDir = Find-PHP -version $phpVersion

if (! $phpDir) {
	if ($phpVersion) {
		throw [System.IO.FileNotFoundException] "[mphp] No PHP $phpVersion executable not found"
	} else {
		throw [System.IO.FileNotFoundException] "[mphp] No PHP executable found. Try to specifiy the version."
	}
}

& $phpDir/php.exe @args