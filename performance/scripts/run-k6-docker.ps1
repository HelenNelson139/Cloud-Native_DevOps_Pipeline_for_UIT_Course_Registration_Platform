param(
  [string]$BaseUrl = "http://20.44.237.162",
  [string]$StudentId = "23520718",
  [string]$Password = "password",
  [int]$Vus = 20,
  [string]$Duration = "3m",
  [string]$ThinkTimeSeconds = "1",
  [string]$Script = "performance/k6/registration-readonly.js",
  [string]$OutFile = "performance/reports/k6-summary.json"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path (Split-Path $OutFile -Parent) | Out-Null

$repoRoot = (Resolve-Path ".").Path
$containerScript = "/repo/" + ($Script -replace "\\", "/")
$containerOut = "/repo/" + ($OutFile -replace "\\", "/")

docker run --rm `
  -i `
  -v "${repoRoot}:/repo" `
  -e BASE_URL="$BaseUrl" `
  -e STUDENT_ID="$StudentId" `
  -e PASSWORD="$Password" `
  -e VUS="$Vus" `
  -e DURATION="$Duration" `
  -e THINK_TIME_SECONDS="$ThinkTimeSeconds" `
  grafana/k6:latest run `
  --summary-export "$containerOut" `
  "$containerScript"

Write-Output "summary=$OutFile"

