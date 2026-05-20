# Scan project for duplicate Godot UIDs across .import, .tres, .tscn,
# and .uid sidecar files. Hash source files to detect byte-identical
# duplicates vs differing duplicates. Writes JSON report.

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$excludeDirs = @(".godot", ".git", "scripts")

function Get-RelativePath {
    param([string]$Path)
    $rel = $Path.Substring($projectRoot.Length).TrimStart("\","/")
    return $rel -replace "\\","/"
}

function Get-Md5OrNull {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    try {
        return (Get-FileHash -LiteralPath $Path -Algorithm MD5).Hash.ToLower()
    } catch {
        return $null
    }
}

function Extract-UidFromImport {
    param([string]$Path)
    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { return $null }
    if ($content -match '(?m)^uid="(uid://[a-z0-9]+)"\s*$') {
        return $Matches[1]
    }
    return $null
}

function Extract-UidFromResource {
    param([string]$Path)
    try {
        $reader = [System.IO.StreamReader]::new($Path, [System.Text.Encoding]::UTF8)
        $firstLine = $reader.ReadLine()
        $reader.Close()
    } catch {
        return $null
    }
    if (-not $firstLine) { return $null }
    if ($firstLine -match '^\[(gd_resource|gd_scene)\b[^\]]*\buid="(uid://[a-z0-9]+)"') {
        return $Matches[2]
    }
    return $null
}

function Extract-UidFromSidecar {
    param([string]$Path)
    $content = (Get-Content -LiteralPath $Path -Raw -Encoding UTF8 -ErrorAction SilentlyContinue)
    if (-not $content) { return $null }
    $content = $content.Trim()
    if ($content -match '^(uid://[a-z0-9]+)') {
        return $Matches[1]
    }
    return $null
}

$uidMap = @{}
$scanned = 0

Write-Host "Scanning $projectRoot ..."

Get-ChildItem -LiteralPath $projectRoot -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $f = $_
    $relDir = Get-RelativePath $f.DirectoryName
    foreach ($ex in $excludeDirs) {
        if ($relDir -eq $ex -or $relDir.StartsWith("$ex/")) { return }
    }

    $name = $f.Name
    $uid = $null
    $sourcePath = $null
    $kind = $null

    if ($name.EndsWith(".import")) {
        $uid = Extract-UidFromImport $f.FullName
        $sourcePath = $f.FullName.Substring(0, $f.FullName.Length - ".import".Length)
        $kind = "import"
    } elseif ($name.EndsWith(".uid")) {
        $uid = Extract-UidFromSidecar $f.FullName
        $sourcePath = $f.FullName.Substring(0, $f.FullName.Length - ".uid".Length)
        $kind = "uid_sidecar"
    } elseif ($name.EndsWith(".tres") -or $name.EndsWith(".tscn")) {
        $uid = Extract-UidFromResource $f.FullName
        $sourcePath = $f.FullName
        $kind = "resource"
    } else {
        return
    }

    $script:scanned++

    if (-not $uid) { return }

    $hash = if ($sourcePath -and (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        Get-Md5OrNull $sourcePath
    } else { $null }

    $entry = [PSCustomObject]@{
        uid_file = Get-RelativePath $f.FullName
        source   = if ($sourcePath -and (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { Get-RelativePath $sourcePath } else { $null }
        kind     = $kind
        hash     = $hash
    }

    if (-not $uidMap.ContainsKey($uid)) {
        $uidMap[$uid] = New-Object System.Collections.ArrayList
    }
    [void]$uidMap[$uid].Add($entry)
}

$duplicates = @{}
foreach ($k in $uidMap.Keys) {
    if ($uidMap[$k].Count -gt 1) { $duplicates[$k] = $uidMap[$k] }
}

$summary = [ordered]@{
    files_scanned = $scanned
    uids_with_duplicates = $duplicates.Count
    byte_identical_groups = 0
    differing_groups = 0
    groups = @()
}

foreach ($k in ($duplicates.Keys | Sort-Object)) {
    $entries = $duplicates[$k]
    $hashes = @($entries | ForEach-Object { $_.hash } | Where-Object { $_ } | Select-Object -Unique)
    $hasNull = ($entries | Where-Object { -not $_.hash }).Count -gt 0
    $identical = ($hashes.Count -eq 1) -and (-not $hasNull)
    if ($identical) { $summary.byte_identical_groups++ } else { $summary.differing_groups++ }
    $summary.groups += [PSCustomObject]@{
        uid = $k
        byte_identical = $identical
        entries = $entries
    }
}

$out = Join-Path $PSScriptRoot "uid_duplicates_report.json"
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $out -Encoding utf8

Write-Host "Scanned $scanned files"
Write-Host "Found $($duplicates.Count) UIDs with duplicates"
Write-Host "  byte-identical groups: $($summary.byte_identical_groups)"
Write-Host "  groups with differing content: $($summary.differing_groups)"
Write-Host "Report: $out"
