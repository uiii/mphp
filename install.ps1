param(
	[string] $installDir = (Join-Path $env:SystemDrive "tools\mphp")
)

function Get-Version
{
	param(
		[string] $versionFile
	)

	if (-Not (Test-Path -PathType Leaf $versionFile)) {
		return $null, $null
	}

	$content = if ($versionFile -Match "^https?://") {
		(New-Object System.Net.WebClient).DownloadString($versionFile)
	} else {
		Get-Content ($versionFile) -ErrorAction Ignore
	}

	$project, [version] $version = $content.Split("@")
	
	return $project, $version
}

$url = "https://github.com/uiii/mphp/archive/master.zip"
$versionUrl = "https://raw.githubusercontent.com/uiii/mphp/master/.version"

# use TLS 1.2 for web requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# check if installed from local or remote file
$isLocalInstall = $false

if ($PSScriptRoot) {
	$project, $null = Get-Version (Join-Path $PSScriptRoot ".version")
	$isLocalInstall = ($project -eq "mphp")	
}

# obtain source files
$sourceFilesDir = $null

if ($isLocalInstall) {
	Write-Host "Local install detected"

	$sourceFilesDir = $PSScriptRoot	
} else {
	Write-Host "Remote install detected"
	Write-Host "Downloding from ${url}"

	# prepare tmp file
	$tmpFile = New-TemporaryFile

	$zipFile = $tmpFile.FullName + '.zip'
	$extractDir = $tmpFile.FullName + ".extract"

	# download zip
	$tmpFile.MoveTo($zipFile)
	Invoke-WebRequest -Uri $url -OutFile $zipFile

	# extract
	Expand-Archive -LiteralPath $zipFile -DestinationPath $extractDir

	$sourceFilesDir = (Join-Path $extractDir "mphp-master")
}

# check if not already installed
if (Test-Path $installDir) {
	$versionFile = Join-Path $installDir ".version"

	try {
		$project, [version] $installedVersion = Get-Version $versionFile
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

Write-Host "Installing from ${sourceFilesDir}"
Write-Host "           to   ${installDir}"

# create install directory
Remove-Item -LiteralPath $installDir -Recurse -Force -ErrorAction Ignore
New-Item -ItemType Directory -Force $installDir | Out-Null

$items = Get-ChildItem -Path "${sourceFilesDir}\*"

foreach ($item in $items) {
	Copy-Item -LiteralPath $item -Destination $installDir -Recurse
}

if (-Not $isLocalInstall) {
	# clean
	Remove-Item -LiteralPath $zipFile -ErrorAction Ignore
	Remove-Item -LiteralPath $extractDir -Recurse -ErrorAction Ignore
}

# set system environment PATH
$binPath = Join-Path $installDir "bin"

$environmentPath = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment").Path

if (-Not $environmentPath.ToLower().Contains($binPath.ToLower())) {
	$environmentPath = "$binPath;$environmentPath"
}

Write-Host "Adding ${binPath} to system PATH environment variable"
setx /m PATH $environmentPath | Out-Null