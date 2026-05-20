# Apply UID-duplicate fixes based on the report from scan_uid_duplicates.ps1.
# For each duplicate group, pick a "winner" (most-referenced entry) and
# regenerate fresh UIDs on the losing entries' files.
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\fix_uid_duplicates.ps1 [-DryRun]

param([switch]$DryRun)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$reportPath = Join-Path $PSScriptRoot "uid_duplicates_report.json"
if (-not (Test-Path -LiteralPath $reportPath)) {
    throw "Report not found: $reportPath. Run scan_uid_duplicates.ps1 first."
}
$report = Get-Content -LiteralPath $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json

# --- Build the set of all UIDs currently used in the project, to avoid
#     generating a new UID that collides with any existing one.
Write-Host "Collecting existing UIDs..."
$usedUids = @{}
$rxUidAny = [regex]'uid://[a-z0-9]+'

Get-ChildItem -LiteralPath $projectRoot -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $rel = $_.FullName.Substring($projectRoot.Length).TrimStart("\","/") -replace "\\","/"
    if ($rel.StartsWith(".godot/") -or $rel.StartsWith(".git/") -or $rel.StartsWith("scripts/")) { return }
    $ext = $_.Extension.ToLower()
    if ($ext -notin @(".import", ".tres", ".tscn", ".uid", ".gd")) { return }
    try {
        $content = [System.IO.File]::ReadAllText($_.FullName)
    } catch { return }
    foreach ($m in $rxUidAny.Matches($content)) { $usedUids[$m.Value] = $true }
}
Write-Host "  $($usedUids.Count) distinct UIDs in use"

function New-GodotUid {
    $charset = "bcdfghijklmnopqrstuvwxyz23456789"
    while ($true) {
        $sb = [System.Text.StringBuilder]::new()
        for ($i = 0; $i -lt 13; $i++) {
            [void]$sb.Append($charset[(Get-Random -Minimum 0 -Maximum $charset.Length)])
        }
        $uid = "uid://" + $sb.ToString()
        if (-not $usedUids.ContainsKey($uid)) {
            $usedUids[$uid] = $true
            return $uid
        }
    }
}

# --- Index ext_resource references in scenes/resources, for picking winners.
#     Build $refsByUid = { uid => { path => count } }
Write-Host "Indexing ext_resource / sub_resource references..."
$refsByUid = @{}
$rxRef1 = [regex]'\[(?:ext_resource|sub_resource)[^\]]*?\buid="(uid://[a-z0-9]+)"[^\]]*?\bpath="res://([^"]+)"'
$rxRef2 = [regex]'\[(?:ext_resource|sub_resource)[^\]]*?\bpath="res://([^"]+)"[^\]]*?\buid="(uid://[a-z0-9]+)"'

Get-ChildItem -LiteralPath $projectRoot -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $rel = $_.FullName.Substring($projectRoot.Length).TrimStart("\","/") -replace "\\","/"
    if ($rel.StartsWith(".godot/") -or $rel.StartsWith(".git/") -or $rel.StartsWith("scripts/")) { return }
    $ext = $_.Extension.ToLower()
    if ($ext -notin @(".tscn", ".tres")) { return }
    try {
        $content = [System.IO.File]::ReadAllText($_.FullName)
    } catch { return }
    foreach ($m in $rxRef1.Matches($content)) {
        $u = $m.Groups[1].Value; $p = $m.Groups[2].Value
        if (-not $refsByUid.ContainsKey($u)) { $refsByUid[$u] = @{} }
        if (-not $refsByUid[$u].ContainsKey($p)) { $refsByUid[$u][$p] = 0 }
        $refsByUid[$u][$p]++
    }
    foreach ($m in $rxRef2.Matches($content)) {
        $p = $m.Groups[1].Value; $u = $m.Groups[2].Value
        if (-not $refsByUid.ContainsKey($u)) { $refsByUid[$u] = @{} }
        if (-not $refsByUid[$u].ContainsKey($p)) { $refsByUid[$u][$p] = 0 }
        $refsByUid[$u][$p]++
    }
}
Write-Host "  $($refsByUid.Count) UIDs referenced from scenes/resources"

# --- Pick winner per group, regenerate UID on losers.
$plan = New-Object System.Collections.ArrayList

foreach ($g in $report.groups) {
    $uid = $g.uid
    $entries = $g.entries

    $scored = foreach ($e in $entries) {
        $count = 0
        if ($e.source -and $refsByUid.ContainsKey($uid) -and $refsByUid[$uid].ContainsKey($e.source)) {
            $count = $refsByUid[$uid][$e.source]
        }
        [PSCustomObject]@{ entry = $e; ref_count = $count }
    }

    $winner = $scored |
        Sort-Object -Property @{Expression="ref_count"; Descending=$true},
                              @{Expression={$_.entry.uid_file}; Descending=$false} |
        Select-Object -First 1

    foreach ($s in $scored) {
        if ($s -eq $winner) {
            [void]$plan.Add([PSCustomObject]@{
                uid       = $uid
                file      = $s.entry.uid_file
                kind      = $s.entry.kind
                ref_count = $s.ref_count
                role      = "keep"
                new_uid   = $null
            })
        } else {
            [void]$plan.Add([PSCustomObject]@{
                uid       = $uid
                file      = $s.entry.uid_file
                kind      = $s.entry.kind
                ref_count = $s.ref_count
                role      = "regenerate"
                new_uid   = $null
            })
        }
    }
}

$regenCount = ($plan | Where-Object { $_.role -eq "regenerate" }).Count
$keepCount  = ($plan | Where-Object { $_.role -eq "keep" }).Count
Write-Host "Plan: $keepCount entries kept, $regenCount entries to regenerate"

if ($DryRun) {
    $logPath = Join-Path $PSScriptRoot "uid_duplicates_plan.json"
    $plan | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $logPath -Encoding utf8
    Write-Host "Dry-run plan written: $logPath"
    return
}

# --- Apply the patches.
$patched = 0; $noMatch = 0; $missing = 0
foreach ($item in $plan) {
    if ($item.role -ne "regenerate") { continue }

    $absPath = Join-Path $projectRoot ($item.file -replace "/","\")
    if (-not (Test-Path -LiteralPath $absPath -PathType Leaf)) {
        $item.new_uid = $null
        $missing++
        continue
    }

    $newUid = New-GodotUid
    $content = [System.IO.File]::ReadAllText($absPath)
    $patchedText = $null

    switch ($item.kind) {
        "import" {
            $patchedText = [regex]::Replace($content, '(?m)^uid="uid://[a-z0-9]+"', "uid=`"$newUid`"", 1)
        }
        "resource" {
            # Replace uid="..." inside the first [gd_resource ...] / [gd_scene ...] header.
            $patchedText = [regex]::Replace(
                $content,
                '^(\[(?:gd_resource|gd_scene)[^\]]*?\buid=)"uid://[a-z0-9]+"',
                "`$1`"$newUid`"",
                1
            )
        }
        "uid_sidecar" {
            $patchedText = "$newUid`n"
        }
    }

    if ($null -ne $patchedText -and $patchedText -ne $content) {
        [System.IO.File]::WriteAllText($absPath, $patchedText, $utf8NoBom)
        $item.new_uid = $newUid
        $patched++
    } else {
        $item.new_uid = $null
        $noMatch++
    }
}

# --- Write final log.
$logPath = Join-Path $PSScriptRoot "uid_duplicates_fixlog.json"
$plan | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $logPath -Encoding utf8

Write-Host "Done."
Write-Host "  patched : $patched"
Write-Host "  no-match: $noMatch"
Write-Host "  missing : $missing"
Write-Host "Log: $logPath"
