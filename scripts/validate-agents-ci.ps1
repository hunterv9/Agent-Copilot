#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$agents = Get-ChildItem "$root/.github/agents/*.agent.md"
if ($agents.Count -lt 9) { Write-Error "agents count $($agents.Count) < 9"; exit 1 }
$allowedTools = @('read','edit','search','execute','web','agent','todo')
$allowedModels = @('claude-opus-5','claude-fable-5-1')
foreach ($f in $agents) {
  $t = Get-Content $f.FullName -Raw
  if ($t -notmatch '(?s)^---(.*?)---') { Write-Error "$($f.Name) missing frontmatter"; exit 1 }
  $fm = $Matches[1]
  foreach ($k in @('name','description','tools','model')) { if ($fm -notmatch "$k\s*:") { Write-Error "$($f.Name) missing $k"; exit 1 } }
  if ($fm -match 'tools:\s*\[(.*?)\]') { foreach ($tool in $Matches[1] -split ',' ) { $tool = $tool.Trim(); if ($tool -and $tool -notin $allowedTools) { Write-Error "$($f.Name) bad tool $tool"; exit 1 } } }
  if ($fm -match 'model:\s*"([^"]+)"' -and $Matches[1] -notin $allowedModels) { Write-Error "$($f.Name) bad model $($Matches[1])"; exit 1 }
}
# ponytail: checks frontmatter only, add handoff/link/VSIX checks when drift seen
Write-Output "OK $($agents.Count) agents"
