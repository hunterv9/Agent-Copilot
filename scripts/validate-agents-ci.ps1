#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$agents = Get-ChildItem "$root/.github/agents/*.agent.md"
if ($agents.Count -lt 9) { Write-Error "agents count $($agents.Count) < 9"; exit 1 }
$allowedTools = @('read','edit','search','execute','web','agent','todo')
$allowedModels = @('claude-opus-5','claude-fable-5-1')
$names = @{}
foreach ($f in $agents) {
  $t = Get-Content $f.FullName -Raw
  if ($t -notmatch '(?s)^---(.*?)---') { Write-Error "$($f.Name) missing frontmatter"; exit 1 }
  $fm = $Matches[1]
  foreach ($k in @('name','description','tools','model')) { if ($fm -notmatch "$k\s*:") { Write-Error "$($f.Name) missing $k"; exit 1 } }
  if ($fm -match '(?m)^name:\s*"([^"]+)"') { $n = $Matches[1]; if ($names.ContainsKey($n)) { Write-Error "duplicate name $n"; exit 1 }; $names[$n] = $f.Name }
  if ($fm -match 'tools:\s*\[(.*?)\]') { foreach ($tool in $Matches[1] -split ',' ) { $tool = $tool.Trim(); if ($tool -and $tool -notin $allowedTools) { Write-Error "$($f.Name) bad tool $tool"; exit 1 } } }
  foreach ($m in [regex]::Matches($fm, 'model:\s*"([^"]+)"')) { if ($m.Groups[1].Value -notin $allowedModels) { Write-Error "$($f.Name) bad model $($m.Groups[1].Value)"; exit 1 } }
}
$all = ($agents | ForEach-Object { Get-Content $_.FullName -Raw }) -join "`n"
if ($all -match 'Free_Model|Team_Lead') { Write-Error "deprecated model ID"; exit 1 }
if ($all -match 'tools:\s*\[[^\]]*\bartifact\b') { Write-Error "unsupported artifact tool"; exit 1 }
$tl = Join-Path $root '.github/agents/team-lead.agent.md'
if (Test-Path $tl) {
  $t = Get-Content $tl -Raw
  if ($t -match 'agents:\s*\[(.*?)\]') { foreach ($a in $Matches[1] -split ',') { $a = $a.Trim().Trim('"'); if ($a -and -not $names.ContainsKey($a)) { Write-Error "unknown agent $a"; exit 1 } } }
  foreach ($m in [regex]::Matches($t, '(?m)^\s*agent:\s*"([^"]+)"')) { if (-not $names.ContainsKey($m.Groups[1].Value)) { Write-Error "unknown handoff $($m.Groups[1].Value)"; exit 1 } }
}
# ponytail: file-config checks only, add runtime/VSIX/provenance checks when needed
Write-Output "OK $($agents.Count) agents"
