# Prints one hash for a built site, leaving out the build time, so two builds of the same
# content give the same hash. The build workflow uses it to skip a deploy that would change
# nothing. The build time is in two places: "generated_at" in the mod index, and the feed's own
# <updated> line (two spaces deep; the entries' lines are four deep and are release dates).
param([Parameter(Mandatory)][string]$Site)
$ErrorActionPreference = "Stop"
$root = (Resolve-Path $Site).Path
# Paths relative to the site, with forward slashes, in a fixed order.
Push-Location $root
try {
    $paths = @(Get-ChildItem -Recurse -File -Force |
        ForEach-Object { (Resolve-Path -LiteralPath $_.FullName -Relative) -replace '^\.[\\/]', '' -replace '\\', '/' } |
        Where-Object { $_ -ne "build-hash.txt" })
} finally {
    Pop-Location
}
[Array]::Sort($paths, [StringComparer]::Ordinal)

$sha = [Security.Cryptography.SHA256]::Create()
function Get-Hex([byte[]]$bytes) {
    [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-", "").ToLower()
}
$timed = @{
    "api/v1/index.json" = '(?m)^\s*"generated_at":.*\r?\n'
    "updates.xml"       = '(?m)^  <updated>.*\r?\n'
}
$lines = foreach ($path in $paths) {
    $bytes = [IO.File]::ReadAllBytes((Join-Path $root $path))
    if ($timed.ContainsKey($path)) {
        $text = [Text.Encoding]::UTF8.GetString($bytes) -replace $timed[$path], ""
        $bytes = [Text.Encoding]::UTF8.GetBytes($text)
    }
    "$path $(Get-Hex $bytes)"
}
Get-Hex ([Text.Encoding]::UTF8.GetBytes(($lines -join "`n")))
