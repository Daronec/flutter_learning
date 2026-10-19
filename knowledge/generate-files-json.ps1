# Скрипт для генерации _files.json для всех глав
# Запустить из директории knowledge/

$knowledgeRoot = "C:/Work/flutter_learning/knowledge"
$chapters = Get-ChildItem -Path $knowledgeRoot -Directory -Filter "chapter-*"

foreach ($chapter in $chapters) {
    Write-Host "Processing: $($chapter.Name)"
    
    $files = Get-ChildItem -Path $chapter.FullName -Filter "*.md" | 
        Sort-Object Name |
        ForEach-Object {
            [PSCustomObject]@{
                name = $_.Name
                path = "$($chapter.Name)/$($_.Name)"
                size = $_.Length
            }
        }
    
    $output = @{
        chapter = $chapter.Name
        files = $files
    } | ConvertTo-Json -Depth 3
    
    $outputPath = Join-Path $chapter.FullName "_files.json"
    $output | Out-File -FilePath $outputPath -Encoding UTF8
    
    Write-Host "  -> Created: $outputPath ($($files.Count) files)"
}

Write-Host "`nDone! Generated _files.json for $($chapters.Count) chapters."


# Regenerate data.js after updating _files.json
Write-Host "`nRegenerating data.js..."
& "$knowledgeRoot\generate-data-js.ps1"
