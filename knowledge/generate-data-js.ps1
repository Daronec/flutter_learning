# Скрипт для генерации data.js — встраивает все данные для работы через file://
# Запустить из директории knowledge/

$knowledgeRoot = "C:/Work/flutter_learning/knowledge"
$chapters = Get-ChildItem -Path $knowledgeRoot -Directory -Filter "chapter-*" | Sort-Object Name

$parts = [System.Collections.Generic.List[string]]::new()
$parts.Add("// Auto-generated file. Do not edit manually.")
$parts.Add("// Run generate-data-js.ps1 to regenerate.")
$parts.Add("// Contains all chapter file lists and lesson content for offline (file://) use.")
$parts.Add("const CHAPTER_FILES = {")

foreach ($chapter in $chapters) {
    $filesJson = Join-Path $chapter.FullName "_files.json"
    if (-not (Test-Path $filesJson)) { continue }
    $data = Get-Content $filesJson -Raw | ConvertFrom-Json
    $files = $data.files | Sort-Object name
    $entries = $files | ForEach-Object { "    { name: `"$($_.name)`", path: `"$($_.path)`", size: $($_.size) }" }
    $parts.Add("  `"$($chapter.Name)`": [")
    $parts.Add(($entries -join ",`n"))
    $parts.Add("  ],")
}

$parts.Add("};")
$parts.Add("")
$parts.Add("const LESSON_CONTENT = {")

foreach ($chapter in $chapters) {
    $filesJson = Join-Path $chapter.FullName "_files.json"
    if (-not (Test-Path $filesJson)) { continue }
    $data = Get-Content $filesJson -Raw | ConvertFrom-Json
    $files = $data.files | Sort-Object name
    foreach ($file in $files) {
        $jsonName = $file.name -replace '\.md$', '.json'
        $jsonPath = Join-Path $chapter.FullName $jsonName
        if (-not (Test-Path $jsonPath)) { continue }
        $rawJson = [System.IO.File]::ReadAllText($jsonPath, [System.Text.Encoding]::UTF8)
        $key = "$($chapter.Name)/$jsonName"
        $parts.Add("  `"$key`": $rawJson,")
    }
}

$parts.Add("};")

$outputPath = Join-Path $knowledgeRoot "data.js"
[System.IO.File]::WriteAllLines($outputPath, $parts, [System.Text.Encoding]::UTF8)

$size = (Get-Item $outputPath).Length
Write-Host "Done! Generated data.js: $([math]::Round($size/1024, 1)) KB"
