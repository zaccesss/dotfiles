# reads and writes the schematic colours inside a Proteus 8 design template (.DTF) or a design's
# ROOT.DSN. both are ISIS schematic files that start with the same "DESIGN CONFIGURATION DATA"
# block: a fixed record of design colours, then a counted list of graphics styles and a counted
# list of text styles. colours are stored as Windows COLORREF values (red, green, blue, 0).
# the layout was mapped by writing a distinct colour into each slot and reading it back in
# Proteus's own Set Design Colours, Set Graphic Styles and Set Text Styles dialogs.

# design colour offsets from the start of the "DESIGN CONFIGURATION DATA" marker
$script:DesignSlots = [ordered]@{
    paper = 0x264; grid = 0xb4; workArea = 0x270; worldBox = 0x274; highlight = 0x268; drag = 0x26c
    hidden = 0x94; positive = 0x280; ground = 0x284; negative = 0x288
    logic1 = 0x28c; logic0 = 0x290; logicUnknown = 0x294
}

function Find-Bytes([byte[]]$Bytes, [byte[]]$Pattern, [int]$From = 0) {
    for ($i = $From; $i -le $Bytes.Length - $Pattern.Length; $i++) {
        $hit = $true
        for ($j = 0; $j -lt $Pattern.Length; $j++) { if ($Bytes[$i + $j] -ne $Pattern[$j]) { $hit = $false; break } }
        if ($hit) { return $i }
    }
    -1
}

# every colour slot in the file as name -> byte offset. $null when the file is not laid out as expected
function Get-TemplateSlots([byte[]]$Bytes) {
    $latin = [Text.Encoding]::GetEncoding(28591)
    $marker = Find-Bytes $Bytes $latin.GetBytes('DESIGN CONFIGURATION DATA')
    if ($marker -lt 0) { return $null }
    $slots = [ordered]@{}
    foreach ($k in $script:DesignSlots.Keys) { $slots["design.$k"] = $marker + $script:DesignSlots[$k] }
    # graphics styles: a 16-bit count, then [name length][name][body], the body's second byte
    # holding its length less one; line colour at +10, fill at +15 and background fill at +19
    $p = Find-Bytes $Bytes ([byte[]](@(9) + $latin.GetBytes('COMPONENT') + @(1))) $marker
    if ($p -lt 2) { return $null }
    $count = [BitConverter]::ToUInt16($Bytes, $p - 2)
    for ($n = 0; $n -lt $count; $n++) {
        $name = $latin.GetString($Bytes, $p + 1, $Bytes[$p]); $body = $p + 1 + $Bytes[$p]
        if ($name -notmatch '^[A-Z0-9 ]+$') { return $null }
        $slots["style.$name.line"] = $body + 10; $slots["style.$name.fill"] = $body + 15; $slots["style.$name.back"] = $body + 19
        $p = $body + $Bytes[$body + 1] + 1
    }
    # text styles: the same shape, with the text colour at +13
    $count = [BitConverter]::ToUInt16($Bytes, $p); $p += 2
    for ($n = 0; $n -lt $count; $n++) {
        $name = $latin.GetString($Bytes, $p + 1, $Bytes[$p]); $body = $p + 1 + $Bytes[$p]
        if ($name -notmatch '^[A-Z0-9 ]+$') { return $null }
        $slots["text.$name"] = $body + 13
        $p = $body + $Bytes[$body + 1] + 1
    }
    $slots
}

function Read-TemplateColours([byte[]]$Bytes) {
    $slots = Get-TemplateSlots $Bytes
    if (-not $slots) { return $null }
    $out = [ordered]@{}
    foreach ($k in $slots.Keys) { $o = $slots[$k]; $out[$k] = '#{0:x2}{1:x2}{2:x2}' -f $Bytes[$o], $Bytes[$o + 1], $Bytes[$o + 2] }
    $out
}

# writes each "#rrggbb" in $Colours (keyed like Get-TemplateSlots) into $Bytes; returns how many changed
function Write-TemplateColours([byte[]]$Bytes, $Colours) {
    $slots = Get-TemplateSlots $Bytes
    if (-not $slots) { return -1 }
    $changed = 0
    foreach ($k in $Colours.Keys) {
        if (-not $slots.Contains($k)) { continue }
        $o = $slots[$k]; $hex = $Colours[$k].TrimStart('#')
        $rgb = 0, 2, 4 | ForEach-Object { [Convert]::ToByte($hex.Substring($_, 2), 16) }
        if ($Bytes[$o] -ne $rgb[0] -or $Bytes[$o + 1] -ne $rgb[1] -or $Bytes[$o + 2] -ne $rgb[2]) {
            $Bytes[$o] = $rgb[0]; $Bytes[$o + 1] = $rgb[1]; $Bytes[$o + 2] = $rgb[2]; $changed++
        }
    }
    $changed
}
