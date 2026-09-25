$ErrorActionPreference = 'Stop'
$broken = @()
$fenceErrors = @()

foreach ($file in Get-ChildItem -Path 'docs' -Filter '*.md' -Recurse) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $fenceCount = ([regex]::Matches($content, '(?m)^```')).Count
    if (($fenceCount % 2) -ne 0) { $fenceErrors += $file.FullName }

    foreach ($match in [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')) {
        $target = $match.Groups[1].Value
        if ($target -match '^(https?://|mailto:|#)') { continue }
        $pathOnly = ($target -split '#')[0]
        if ([string]::IsNullOrWhiteSpace($pathOnly)) { continue }
        $resolved = Join-Path $file.DirectoryName $pathOnly
        if (-not (Test-Path -LiteralPath $resolved)) {
            $broken += "$($file.FullName): $target"
        }
    }
}

if ($broken.Count -gt 0 -or $fenceErrors.Count -gt 0) {
    $broken | ForEach-Object { Write-Error "Broken link: $_" }
    $fenceErrors | ForEach-Object { Write-Error "Unpaired fence: $_" }
    exit 1
}

Write-Output 'Documentation check passed: no broken relative links or unpaired fences.'
