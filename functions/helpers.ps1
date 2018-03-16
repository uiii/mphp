$cachePath = (Join-Path $PSScriptRoot "../.cache")

function Get-Cache 
{
	$content = Get-Content -Encoding UTF8 -Path $cachePath -ErrorAction Ignore
	$csv = $content | ConvertFrom-Csv -Delimiter '|' -Header 'Version','Path' 
	$cache = @($csv | Foreach-Object { [PSCustomObject]@{Version = [version] $_.Version; Path = $_.Path} })

	$cachedPaths = $cache | Select-Object -ExpandProperty 'Path'
	$foundPaths = where.exe php | Where-Object { $_ -match ".exe$" }

	$newPaths = $foundPaths | Where-Object { $cachedPaths -NotContains $_ }
	
	foreach ($path in $newPaths) {
		# get output of `php -v`
		$output = & $path -v 2>&1 | Out-String

		if ($output -NotMatch "PHP [0-9.]+") {
			continue
		}
		
		$version = [version]$output.Split(' ')[1];
		$cache += [PSCustomObject]@{Version=$version;Path=$path}
	}

	# sort cache by version
	$cache = $cache | Sort-Object -Property "Version" -Descending

	# write to file
	$cache | Foreach-Object { "$($_.Version.toString())|$($_.Path)" } | Out-File $cachePath

	return $cache
}

function Find-PHP
{
	param (
		[string] $version
	)

	$cache = Get-Cache	

	if (! $cache) {
		return $null
	}

	$versionPattern = if (! $version) { "^.*$" } else { "^${version}(\..*|$)" }

	$php = $cache | Where-Object { $_.Version.toString() -Match $versionPattern } | Select-Object -First 1

	return $php.Path
}