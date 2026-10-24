$KnowledgeRoot = Join-Path $PSScriptRoot "knowledge"
$ChapterDirs = Get-ChildItem -Path $KnowledgeRoot -Directory -Filter "chapter-*"

$WikiLinkMap = @{
    "chapter-01" = @("chapter-02", "chapter-03")
    "chapter-02" = @("chapter-03", "chapter-04")
    "chapter-03" = @("chapter-04", "chapter-05", "chapter-06")
    "chapter-04" = @("chapter-05", "chapter-08")
    "chapter-05" = @("chapter-04", "chapter-07")
    "chapter-06" = @("chapter-07", "chapter-08", "chapter-11")
    "chapter-07" = @("chapter-08", "chapter-09")
    "chapter-08" = @("chapter-09", "chapter-10")
    "chapter-09" = @("chapter-10", "chapter-11")
    "chapter-10" = @("chapter-09", "chapter-11")
    "chapter-11" = @("chapter-06", "chapter-13", "chapter-14")
    "chapter-12" = @("chapter-03", "chapter-04")
    "chapter-13" = @("chapter-14", "chapter-11")
    "chapter-14" = @("chapter-13", "chapter-15")
    "chapter-15" = @("chapter-16")
    "chapter-16" = @("chapter-09", "chapter-10")
}

function Get-FirstHeadingTitle {
    param([string]$FilePath)
    $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
    $match = [regex]::Match($content, "^#\s+(\d+\.\d+\s+.+)")
    if ($match.Success) {
        return $match.Groups[1].Value.Trim() -replace "^\d+\.\d+\s+", ""
    }
    return ""
}

foreach ($ChapterDir in $ChapterDirs) {
    $ChapterKey = $ChapterDir.Name
    
    if (-not $WikiLinkMap.ContainsKey($ChapterKey)) { continue }
    
    $RelatedChapters = $WikiLinkMap[$ChapterKey]
    $LinksToAdd = ""
    
    foreach ($RelChapter in $RelatedChapters) {
        $RelChapterDir = Get-ChildItem -Path $KnowledgeRoot -Directory -Filter $RelChapter | Select-Object -First 1
        if ($RelChapterDir) {
            $FirstFile = Get-ChildItem -Path $RelChapterDir.FullName -Filter "*.md" | Select-Object -First 1
            if ($FirstFile) {
                $Title = Get-FirstHeadingTitle -FilePath $FirstFile.FullName
                if ($Title -ne "") {
                    $LinksToAdd += "[[$Title]] "
                }
            }
        }
    }

    if ($LinksToAdd -ne "") {
        $MdFiles = Get-ChildItem -Path $ChapterDir.FullName -Filter "*.md"
        foreach ($File in $MdFiles) {
            $Content = [System.IO.File]::ReadAllText($File.FullName, [System.Text.Encoding]::UTF8)
            
            # Check if already has "Связанные главы" section
            if ($Content -match "Связанные главы") {
                # Replace existing section
                $sectionRegex = New-Object System.Text.RegularExpressions.Regex("##\s+Связанные главы\s*\r?\n\r?\n.*", "SingleLine")
                $replacement = "## Связанные главы`r`n`r`n$LinksToAdd`r`n"
                $NewContent = $sectionRegex.Replace($Content, $replacement, 1)
                [System.IO.File]::WriteAllText($File.FullName, $NewContent, [System.Text.Encoding]::UTF8)
                Write-Host "Updated: $($File.Name)"
            }
        }
    }
}

Write-Host "`nWiki-links updated!" -ForegroundColor Green
