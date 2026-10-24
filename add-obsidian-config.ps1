$KnowledgeRoot = Join-Path $PSScriptRoot "knowledge"
$ChapterDirs = Get-ChildItem -Path $KnowledgeRoot -Directory -Filter "chapter-*"

$ChapterTags = @{
    "chapter-01" = @("flutter", "intro", "basics")
    "chapter-02" = @("dart", "syntax", "basics")
    "chapter-03" = @("widgets", "architecture")
    "chapter-04" = @("widgets", "ui", "basics")
    "chapter-05" = @("layout", "responsive", "ui")
    "chapter-06" = @("state-management", "provider", "bloc", "riverpod")
    "chapter-07" = @("navigation", "routing")
    "chapter-08" = @("forms", "validation")
    "chapter-09" = @("api", "http", "networking")
    "chapter-10" = @("storage", "database", "local")
    "chapter-11" = @("architecture", "clean-architecture", "repository")
    "chapter-12" = @("animations")
    "chapter-13" = @("testing", "unit-tests", "widget-tests")
    "chapter-14" = @("performance", "optimization")
    "chapter-15" = @("build", "deployment", "ci-cd")
    "chapter-16" = @("platform-channels", "native", "plugins")
}

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
    if ($content.StartsWith("---`r`n")) {
        $fmEnd = $content.IndexOf("`r`n`r`n", 3)
        if ($fmEnd -gt 0) { $content = $content.Substring($fmEnd + 4) }
    }
    $match = [regex]::Match($content, "^#\s+(\d+\.\d+\s+.+)")
    if ($match.Success) { return $match.Groups[1].Value.Trim() -replace "^\d+\.\d+\s+", "" }
    $match2 = [regex]::Match($content, "^#\s+(.+)")
    if ($match2.Success) { return $match2.Groups[1].Value.Trim() }
    return ""
}

# Step 1: Add frontmatter to all .md files
Write-Host "Adding frontmatter to all files..." -ForegroundColor Cyan
foreach ($ChapterDir in $ChapterDirs) {
    $ChapterKey = $ChapterDir.Name
    if (-not $ChapterTags.ContainsKey($ChapterKey)) { continue }
    
    $Tags = $ChapterTags[$ChapterKey]
    $ChapterNum = [int]($ChapterKey -replace "chapter-", "")
    
    Get-ChildItem -Path $ChapterDir.FullName -Filter "*.md" | ForEach-Object {
        $Content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
        if ($Content.StartsWith("---")) { return }
        
        $FileName = $_.BaseName
        $SectionNum = [int]($FileName.Split("-")[1])
        $Title = Get-FirstHeadingTitle -FilePath $_.FullName
        $Alias = $FileName -replace "-", " "
        
        $Fm = "---`r`n"
        $Fm += "tags:`r`n"
        foreach ($tag in $Tags) { $Fm += "  - $tag`r`n" }
        $Fm += "chapter: $ChapterNum`r`n"
        $Fm += "section: $SectionNum`r`n"
        $Fm += "title: $Title`r`n"
        $Fm += "alias: $Alias`r`n"
        $Fm += "status: complete`r`n---`r`n`r`n"
        
        [System.IO.File]::WriteAllText($_.FullName, $Fm + $Content, [System.Text.Encoding]::UTF8)
    }
}
Write-Host "  Done!" -ForegroundColor Green

# Step 2: Add wiki-links to first file of each chapter
Write-Host "Adding wiki-links to first files..." -ForegroundColor Cyan
foreach ($ChapterDir in $ChapterDirs) {
    $ChapterKey = $ChapterDir.Name
    if (-not $WikiLinkMap.ContainsKey($ChapterKey)) { continue }
    
    $LinksToAdd = ""
    foreach ($RelChapter in $WikiLinkMap[$ChapterKey]) {
        $RelChapterDir = Get-ChildItem -Path $KnowledgeRoot -Directory -Filter $RelChapter | Select-Object -First 1
        if ($RelChapterDir) {
            $FirstFile = Get-ChildItem -Path $RelChapterDir.FullName -Filter "*.md" | Select-Object -First 1
            if ($FirstFile) {
                $Title = Get-FirstHeadingTitle -FilePath $FirstFile.FullName
                if ($Title -ne "") { $LinksToAdd += "[[$Title]] " }
            }
        }
    }

    if ($LinksToAdd -ne "") {
        $FirstFile = Get-ChildItem -Path $ChapterDir.FullName -Filter "*.md" | Select-Object -First 1
        if ($FirstFile) {
            $Content = [System.IO.File]::ReadAllText($FirstFile.FullName, [System.Text.Encoding]::UTF8)
            $section = "`r`n## Связанные главы`r`n`r`n$LinksToAdd`r`n"
            [System.IO.File]::WriteAllText($FirstFile.FullName, $Content.TrimEnd() + $section, [System.Text.Encoding]::UTF8)
            Write-Host "  $($FirstFile.Name): $LinksToAdd" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nAll done!" -ForegroundColor Green
