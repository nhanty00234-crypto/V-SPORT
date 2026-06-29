# Find all jars in .m2 repository
$m2Repo = "$env:USERPROFILE\.m2\repository"
if (-not (Test-Path $m2Repo)) {
    Write-Error "Local Maven repository (.m2) not found at $m2Repo"
    exit 1
}

Write-Host "Collecting jar files from $m2Repo..."
$jars = Get-ChildItem -Path $m2Repo -Filter "*.jar" -Recurse | Select-Object -ExpandProperty FullName
Write-Host "Found $($jars.Count) jar files."

# Build classpath
$cp = [string]::Join(";", $jars)

# Compile TestEmail.java
Write-Host "Compiling TestEmail.java..."
$srcFile = "src\main\java\org\example\util\TestEmail.java"
$outputDir = "target\classes"

# Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$compileCmd = "javac -encoding UTF-8 -cp `"$cp;target/classes`" `"$srcFile`" -d `"$outputDir`""
Invoke-Expression $compileCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful!"
    # Run TestEmail
    Write-Host "Running TestEmail..."
    $runCmd = "java -cp `"$cp;target/classes`" org.example.util.TestEmail"
    Invoke-Expression $runCmd
} else {
    Write-Error "Compilation failed."
}
