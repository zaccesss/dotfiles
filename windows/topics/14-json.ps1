# =============================================================================
# JSON tools - Windows PowerShell
# Uses built-in ConvertFrom-Json / ConvertTo-Json. jq can be installed via
# winget install stedolan.jq for complex pipeline queries.
# =============================================================================

function jqk {
    param([string]$Path)
    if ($Path) {
        Get-Content $Path | ConvertFrom-Json | ConvertTo-Json -Depth 20
    } else {
        $input | ConvertFrom-Json | ConvertTo-Json -Depth 20
    }
}

function json-keys {
    param([string]$Path)
    (Get-Content $Path | ConvertFrom-Json).PSObject.Properties.Name
}

# jqlen: count items in a JSON array or keys in an object - no jq needed for this one
function jqlen {
    param([string]$Path)
    $data = Get-Content $Path | ConvertFrom-Json
    if ($data -is [System.Array]) { $data.Count } else { ($data.PSObject.Properties | Measure-Object).Count }
}

# _jq_or_hint: the remaining jq-parity functions need real jq filters/flags that
# ConvertFrom-Json can't express, so they pass straight through to jq itself
function _jq_or_hint {
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
        Write-Host "This needs jq installed: winget install stedolan.jq" -ForegroundColor Yellow
        return $false
    }
    return $true
}

# jqf: raw string output - avoids the default quoted output when extracting values
function jqf {
    param([string]$Filter, [string]$Path)
    if (_jq_or_hint) { jq -r $Filter $Path }
}

# jqsort: sort object keys alphabetically at every level
function jqsort {
    param([string]$Path)
    if (_jq_or_hint) { jq -S . $Path }
}

# jqpaths: list all leaf paths in a JSON file - useful for exploring unknown
# schemas from third-party APIs before writing real queries against them
function jqpaths {
    param([string]$Path)
    if (_jq_or_hint) { jq -r '[paths | map(tostring) | join(".")][] | .' $Path | Sort-Object -Unique }
}

# jqmerge: deep-merge two JSON files, values in the second file win on conflict -
# useful for layering a local override file on top of a shared base config
function jqmerge {
    param([string]$Base, [string]$Override)
    if (_jq_or_hint) { jq -s '.[0] * .[1]' $Base $Override }
}

function json-min {
    param([string]$Path)
    Get-Content $Path | ConvertFrom-Json | ConvertTo-Json -Depth 20 -Compress
}

function json-check {
    param([string]$Path)
    try {
        Get-Content $Path | ConvertFrom-Json | Out-Null
        Write-Host "Valid JSON" -ForegroundColor Green
    } catch {
        Write-Host "Invalid JSON: $_" -ForegroundColor Red
    }
}

function json-diff {
    param([string]$File1, [string]$File2)
    if (Get-Command jq -ErrorAction SilentlyContinue) {
        $a = jq -S . $File1
        $b = jq -S . $File2
        Compare-Object $a $b
    } else {
        $a = Get-Content $File1 | ConvertFrom-Json | ConvertTo-Json -Depth 20
        $b = Get-Content $File2 | ConvertFrom-Json | ConvertTo-Json -Depth 20
        Compare-Object ($a -split "`n" | Sort-Object) ($b -split "`n" | Sort-Object)
    }
}
