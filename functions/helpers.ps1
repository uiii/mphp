$cacheDir = (Join-Path $PSScriptRoot "../.cache")

function Find-File
{
	param (
		[string] $name,

		[parameter(Mandatory=$false)]
		[array] $directories
	)

	if (! $directories) {
		$directories = (Get-PSDrive -PSProvider "FileSystem" | Select-Object -ExpandProperty "Root")
	}

	$found = @()

	foreach ($directory in $directories) {
		$files = Get-ChildItem -LiteralPath $directory -Recurse -Filter $name -ErrorAction SilentlyContinue
		$found = $found + $files
	}

	return $found
}

function Get-Cache
{
	param (
		[string] $file,
		[string] $key
	)

	$cache = Get-Content -Encoding UTF8 -Path (Join-Path $cacheDir $file) -ErrorAction Ignore | ConvertFrom-Csv -Delimiter '|' -Header 'Key','Value'

	if (! $key) {
		return $cache
	}

	return $cache | Where-Object { $_.Key -eq $key} | Select-Object -first 1 | Select-Object -ExpandProperty 'Value'
}

function Set-Cache
{
	param (
		[string] $file,
		[string] $key,
		[string] $value
	)

	if (-Not (Test-Path $cacheDir)) {
		New-Item -ItemType Directory -Path $cacheDir | Out-Null
	}

	$key + "|" + $value | Out-File -Append (Join-Path $cacheDir $file)
}

function Find-PHP
{
	param (
		[string] $version
	)

	if (! $version) {
		$cache = Get-Cache -File 'paths'

		$highestVersion = ($cache | Select-Object -ExpandProperty 'Key' | Measure-Object -Maximum).Maximum

		if (! $highestVersion) {
			return $null
		}

		return Find-PHP -version $highestVersion
	}

	$cached = Get-Cache -File 'paths' -Key $version

	if ($cached) {
		return $cached
	}

	Write-Host -NoNewline "[mphp] Searching PHP $version installation ... "

	$executables = Find-File -name "php.exe"

	foreach ($executable in $executables) {
		$output = & $executable.FullName -v 2>&1 | Out-String

		if ($output -NotMatch "PHP $version") {
			continue
		}

		if (Find-File -name "*apache2_4.dll" -directories $executable.Directory.FullName) {
			$path = $executable.Directory.FullName

			Set-Cache -File 'paths' -Key $version -Value $path

			Write-Host -NoNewline "`r                                                 `r"

			return $path
		}
	}

	return $null
}