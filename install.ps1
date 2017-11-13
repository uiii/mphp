param(
	[string] $installDir = (Join-Path $env:LOCALAPPDATA "mphp")
)

$url = "https://github.com/uiii/mphp/archive/master.zip"
$versionUrl = "https://raw.githubusercontent.com/uiii/mphp/master/.version"

if (Test-Path $installDir) {
	$versionFile = Join-Path $installDir ".version"

	try {
		if (-Not (Test-Path -PathType Leaf $versionFile)) {
			throw "Not-MPHP"
		}

		$project, [version] $installedVersion = (Get-Content ($versionFile)).Split("@")
		$null, [version] $latestVersion = (New-Object System.Net.WebClient).DownloadString($versionUrl).Split("@")

		if ($project -ne "mphp") {
			throw "Not-MPHP"
		}

		if ($installedVersion -ge $latestVersion) {
			"Latest version of MPHP@$($installedVersion.ToString()) is already installed."
			return
		}
	} catch {
		if ($_.FullyQualifiedErrorId -eq "Not-MPHP") {
			throw $installDir + ": Install dir is not empty and doesn't contain MPHP project."
		}

		throw $_
	}
}

# prepare tmp file
$tmpFile = New-TemporaryFile

$zipFile = $tmpFile.FullName + '.zip'
$extractDir = $tmpFile.FullName + ".extract"

# download zip
$tmpFile.MoveTo($zipFile)
Invoke-WebRequest -Uri $url -OutFile $zipFile

# extract
Expand-Archive -LiteralPath $zipFile -DestinationPath $extractDir

# create install directory
Remove-Item -LiteralPath $installDir -Recurse -Force -ErrorAction Ignore
New-Item -ItemType Directory -Force $installDir

$items = Get-ChildItem -Path (Join-Path $extractDir "mphp-master\*")

foreach ($item in $items) {
	Copy-Item -LiteralPath $item -Destination $installDir -Recurse
}

# clean
Remove-Item -LiteralPath $zipFile
Remove-Item -LiteralPath $extractDir -Recurse

# set user PATH
$binPath = Join-Path $installDir "bin"

$environmentPath = (Get-ItemProperty -Path Registry::"HKEY_CURRENT_USER\Environment").Path

if (-Not $environmentPath.ToLower().Contains($binPath.ToLower())) {
	$environmentPath = "$environmentPath;$binPath"
}

setx PATH $environmentPath