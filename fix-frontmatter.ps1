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

foreach ($ChapterDir in $ChapterDirs) {
    $ChapterKey = $ChapterDir.Name
    $ChapterNum = $ChapterDir.Name -replace "chapter-", ""
    
    if (-not $ChapterTags.ContainsKey($ChapterKey)) { continue }
    
    $Tags = $ChapterTags[$ChapterKey]
    $TagsYaml = ""
    foreach ($tag in $Tags) {
        $TagsYaml += "  - $tag`r`n"
    }
    
    $MdFiles = Get-ChildItem -Path $ChapterDir.FullName -Filter "*.md"
    foreach ($File in $MdFiles) {
        $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8
        
        # Extract frontmatter
        $fmMatch = $Content | Select-String -Pattern "^---\r?\n([\s\S]*?)^---\r?\n" -MultiLine
        if ($fmMatch.Matches.Count -eq 0) { continue }
        
        $Frontmatter = $fmMatch.Matches[0].Value
        $Body = $Content.Substring($fmMatch.Matches[0].Value.Length)
        
        # Extract chapter and section from filename
        $FileName = $File.BaseName
        $ChapterNumFile = [int]($FileName.Split("-")[0])
        $SectionNum = [int]($FileName.Split("-")[1])
        
        # Extract title
        $Title = ""
        $FirstHeading = $Body | Select-String -Pattern "^#\s+(.+)" -AllMatches | Select-Object -First 1
        if ($FirstHeading) {
            $Title = $FirstHeading.Matches[0].Groups[1].Value.Trim()
            $Title = $Title -replace "^\d+\.\d+\s+", ""
        }
        
        $Alias = $FileName -replace "-", " "
        
        # Build new frontmatter
        $NewFm = "---`r`n"
        $NewFm += "tags:`r`n"
        foreach ($tag in $Tags) {
            $NewFm += "  - $tag`r`n"
        }
        $NewFm += "chapter: $ChapterNumFile`r`n"
        $NewFm += "section: $SectionNum`r`n"
        $NewFm += "title: $Title`r`n"
        $NewFm += "alias: $Alias`r`n"
        $NewFm += "status: complete`r`n"
        $NewFm += "---`r`n`r`n"
        
        $NewContent = $NewFm + $Body
        Set-Content -Path $File.FullName -Value $NewContent -Encoding UTF8BOM -NoNewline
    }
}

Write-Host "Fixed frontmatter tags formatting!" -ForegroundColor Green
