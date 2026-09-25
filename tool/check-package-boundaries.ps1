$ErrorActionPreference = 'Stop'

$violations = @()
$domainFiles = Get-ChildItem -Path 'packages/erp_domain/lib' -Filter '*.dart' -Recurse
foreach ($file in $domainFiles) {
    $matches = Select-String -Path $file.FullName -Pattern "package:(flutter|drift|sqlite3|erp_application|erp_local_data|erp_platform)/"
    if ($matches) { $violations += $matches }
}

$applicationFiles = Get-ChildItem -Path 'packages/erp_application/lib' -Filter '*.dart' -Recurse
foreach ($file in $applicationFiles) {
    $matches = Select-String -Path $file.FullName -Pattern "package:(flutter|drift|sqlite3|erp_local_data|erp_platform)/"
    if ($matches) { $violations += $matches }
}

$presentationFiles = Get-ChildItem -Path 'business_erp/lib' -Filter '*.dart' -Recurse
foreach ($file in $presentationFiles) {
    $matches = Select-String -Path $file.FullName -Pattern "foundation_database\.g\.dart|OrganizationsCompanion|BranchesCompanion|FinancialPeriodsCompanion"
    if ($matches) { $violations += $matches }
}

if ($violations.Count -gt 0) {
    $violations | ForEach-Object { Write-Error $_.Line }
    exit 1
}

Write-Output 'Package boundary check passed.'
