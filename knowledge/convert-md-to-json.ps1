# Конвертер Markdown → JSON (оптимизированный)

$knowledgeRoot = "C:/Work/flutter_learning/knowledge"
$chapters = Get-ChildItem -Path $knowledgeRoot -Directory -Filter "chapter-*"

function FormatInline($text) {
    $text = $text -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
    $text = $text -replace '\*(.+?)\*', '<em>$1</em>'
    $text = $text -replace '`(.+?)`', '<code>$1</code>'
    $text = $text -replace '\[(.+?)\]\((.+?)\)', '<a href="$2" target="_blank">$1</a>'
    return $text
}

function ConvertTo-JsonString($obj) {
    if ($null -eq $obj) { return 'null' }
    if ($obj -is [string]) { return '"' + ($obj -replace '\\', '\\\\' -replace '"', '\"') + '"' }
    if ($obj -is [int]) { return $obj.ToString() }
    if ($obj -is [array]) {
        return '[' + (($obj | ForEach-Object { ConvertTo-JsonString $_ }) -join ', ') + ']'
    }
    if ($obj -is [hashtable]) {
        $props = @()
        foreach ($key in $obj.Keys) {
            $props += '"' + $key + '": ' + (ConvertTo-JsonString $obj[$key])
        }
        return '{' + ($props -join ', ') + '}'
    }
    return 'null'
}

foreach ($chapter in $chapters) {
    Write-Host "Processing: $($chapter.Name)"
    $mdFiles = Get-ChildItem -Path $chapter.FullName -Filter "*.md"
    
    foreach ($mdFile in $mdFiles) {
        $content = Get-Content -Path $mdFile.FullName -Raw -Encoding UTF8
        $lines = $content -split "`n"
        $sections = @()
        $currentList = $null
        $currentCode = $null
        $currentBlockquote = $null
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $trimmed = $lines[$i].Trim()
            
            # Code block start/end
            if ($trimmed -match '^```(\w*)$') {
                if ($currentCode) {
                    $sections += @{ type = 'code'; language = $currentCode.lang; content = $currentCode.content.Trim() }
                    $currentCode = $null
                } else {
                    $currentCode = @{ lang = $Matches[1]; content = '' }
                }
                continue
            }
            if ($currentCode) {
                $currentCode.content += "`n$trimmed"
                continue
            }
            
            # Blockquote
            if ($trimmed.StartsWith('>')) {
                if ($currentList) {
                    $sections += @{ type = $currentList.type; items = $currentList.items }
                    $currentList = $null
                }
                if ($currentBlockquote) { $currentBlockquote += $trimmed.Substring(1).Trim() }
                else { $currentBlockquote = @($trimmed.Substring(1).Trim()) }
                continue
            }
            if ($currentBlockquote) {
                $sections += @{ type = 'blockquote'; content = ($currentBlockquote -join ' ').Trim() }
                $currentBlockquote = $null
            }
            
            # Heading
            if ($trimmed -match '^(#{1,6})\s+(.*)') {
                if ($currentList) {
                    $sections += @{ type = $currentList.type; items = $currentList.items }
                    $currentList = $null
                }
                $sections += @{ type = 'heading'; level = $Matches[1].Length; text = (FormatInline $Matches[2]) }
                continue
            }
            
            # Horizontal rule
            if ($trimmed -match '^(-{3,}|\*{3,}|_{3,})$') {
                if ($currentList) {
                    $sections += @{ type = $currentList.type; items = $currentList.items }
                    $currentList = $null
                }
                $sections += @{ type = 'hr' }
                continue
            }
            
            # Empty line
            if ($trimmed -eq '') { continue }
            
            # Unordered list
            if ($trimmed -match '^[-*+]\s+(.*)') {
                if (-not $currentList -or $currentList.type -ne 'ul') {
                    if ($currentList) {
                        $sections += @{ type = $currentList.type; items = $currentList.items }
                    }
                    $currentList = @{ type = 'ul'; items = @() }
                }
                $currentList.items += (FormatInline $Matches[1])
                continue
            }
            
            # Ordered list
            if ($trimmed -match '^\d+\.\s+(.*)') {
                if (-not $currentList -or $currentList.type -ne 'ol') {
                    if ($currentList) {
                        $sections += @{ type = $currentList.type; items = $currentList.items }
                    }
                    $currentList = @{ type = 'ol'; items = @() }
                }
                $currentList.items += (FormatInline $Matches[1])
                continue
            }
            
            # Paragraph
            if ($currentList) {
                $sections += @{ type = $currentList.type; items = $currentList.items }
                $currentList = $null
            }
            $sections += @{ type = 'paragraph'; text = (FormatInline $trimmed) }
        }
        
        # Flush remaining
        if ($currentList) {
            $sections += @{ type = $currentList.type; items = $currentList.items }
        }
        
        # Build JSON
        $sectionStrings = @()
        foreach ($section in $sections) {
            $sectionStrings += (ConvertTo-JsonString $section)
        }
        $jsonOutput = "{`n  `"sections`": [`n    " + ($sectionStrings -join ",`n    ") + "`n  ]`n}"
        $jsonPath = $mdFile.FullName -replace '\.md$', '.json'
        $jsonOutput | Out-File -FilePath $jsonPath -Encoding UTF8
        Write-Host "  -> $($mdFile.Name)"
    }
}

Write-Host "`nDone!"
