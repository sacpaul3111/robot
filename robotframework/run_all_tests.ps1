param(
    [Parameter(Mandatory=$true)]
    [string]$TargetHostname,
    [string]$SshUsername,
    [string]$SshPassword,
    [string]$VcenterUsername,
    [string]$VcenterPassword,
    [string]$SplunkUsername,
    [string]$SplunkPassword,
    [string]$CyberarkUsername,
    [string]$CyberarkPassword,
    [string]$TaniumUsername,
    [string]$TaniumPassword,
    [string]$AnsibleTowerUsername,
    [string]$AnsibleTowerPassword,
    [string]$OutputDir = "results"
)

Write-Host "GSA Itential Robot Framework - Test Runner" -ForegroundColor Cyan

# Get SSH credentials from environment variables if not provided as parameters
if ([string]::IsNullOrEmpty($SshUsername)) {
    $SshUsername = $env:SSH_USERNAME
    if ([string]::IsNullOrEmpty($SshUsername)) {
        Write-Host "ERROR: SSH Username not provided. Set SSH_USERNAME environment variable or use -SshUsername parameter" -ForegroundColor Red
        exit 1
    }
    Write-Host "Using SSH username from environment variable" -ForegroundColor Yellow
}

if ([string]::IsNullOrEmpty($SshPassword)) {
    $SshPassword = $env:SSH_PASSWORD
    if ([string]::IsNullOrEmpty($SshPassword)) {
        Write-Host "ERROR: SSH Password not provided. Set SSH_PASSWORD environment variable or use -SshPassword parameter" -ForegroundColor Red
        exit 1
    }
    Write-Host "Using SSH password from environment variable" -ForegroundColor Yellow
}

# Get other credentials from environment variables if not provided
if ([string]::IsNullOrEmpty($VcenterUsername)) { $VcenterUsername = $env:VCENTER_USERNAME }
if ([string]::IsNullOrEmpty($VcenterPassword)) { $VcenterPassword = $env:VCENTER_PASSWORD }
if ([string]::IsNullOrEmpty($SplunkUsername)) { $SplunkUsername = $env:SPLUNK_USERNAME }
if ([string]::IsNullOrEmpty($SplunkPassword)) { $SplunkPassword = $env:SPLUNK_PASSWORD }
if ([string]::IsNullOrEmpty($CyberarkUsername)) { $CyberarkUsername = $env:CYBERARK_USERNAME }
if ([string]::IsNullOrEmpty($CyberarkPassword)) { $CyberarkPassword = $env:CYBERARK_PASSWORD }
if ([string]::IsNullOrEmpty($TaniumUsername)) { $TaniumUsername = $env:TANIUM_USERNAME }
if ([string]::IsNullOrEmpty($TaniumPassword)) { $TaniumPassword = $env:TANIUM_PASSWORD }
if ([string]::IsNullOrEmpty($AnsibleTowerUsername)) { $AnsibleTowerUsername = $env:ANSIBLE_TOWER_USERNAME }
if ([string]::IsNullOrEmpty($AnsibleTowerPassword)) { $AnsibleTowerPassword = $env:ANSIBLE_TOWER_PASSWORD }

# Use system Python
$pythonExe = "python.exe"
Write-Host "Using Python: $pythonExe" -ForegroundColor Yellow

# Create results directory
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Find all test directories
$testDirs = Get-ChildItem -Path "tests" -Directory | Where-Object { $_.Name -like "test*_*" }

Write-Host "Found test suites: $($testDirs.Count)" -ForegroundColor Yellow

$allOutputFiles = @()

# Run each test suite
foreach ($testDir in $testDirs) {
    $testId = $testDir.Name.Split("_")[0]
    $suiteName = $testDir.Name
    Write-Host "Running $suiteName..." -ForegroundColor Green

    $suiteDir = "$OutputDir/$suiteName"
    $robotFile = Get-ChildItem -Path $testDir.FullName -Filter "*.robot" | Select-Object -First 1
    
    if ($robotFile) {
        # Run the robot test with visible output
        Write-Host ""
        & $pythonExe -m robot `
            --variable TARGET_HOSTNAME:$TargetHostname `
            --variable TEST_SUITE_ID:$testId `
            --variable SSH_USERNAME:$SshUsername `
            --variable SSH_PASSWORD:"$SshPassword" `
            --variable VCENTER_USERNAME:$VcenterUsername `
            --variable VCENTER_PASSWORD:"$VcenterPassword" `
            --variable SPLUNK_USERNAME:$SplunkUsername `
            --variable SPLUNK_PASSWORD:"$SplunkPassword" `
            --variable CYBERARK_USERNAME:$CyberarkUsername `
            --variable CYBERARK_PASSWORD:"$CyberarkPassword" `
            --variable TANIUM_USERNAME:$TaniumUsername `
            --variable TANIUM_PASSWORD:"$TaniumPassword" `
            --variable ANSIBLE_TOWER_USERNAME:$AnsibleTowerUsername `
            --variable ANSIBLE_TOWER_PASSWORD:"$AnsibleTowerPassword" `
            --outputdir $suiteDir `
            $robotFile.FullName
        Write-Host ""

        # Collect output file for consolidation
        if (Test-Path "$suiteDir/output.xml") {
            $allOutputFiles += "$suiteDir/output.xml"
        }
    }
}

# Create consolidated reports
if ($allOutputFiles.Count -gt 0) {
    Write-Host "Creating consolidated reports..." -ForegroundColor Cyan
    
    # Try using rebot
    try {
        Write-Host ""
        & $pythonExe -m robot.rebot --outputdir $OutputDir --output all_output.xml --log all_log.html --report all_report.html $allOutputFiles
        Write-Host ""
        Write-Host "Consolidated reports created" -ForegroundColor Green
    }
    catch {
        Write-Host "rebot failed, using fallback method..." -ForegroundColor Yellow
        
        # Fallback: copy most recent test results
        $latestTest = $testDirs | Sort-Object Name | Select-Object -Last 1
        $latestTestId = $latestTest.Name.Split("_")[0]
        $sourceDir = "$OutputDir/$latestTestId"
        
        Copy-Item "$sourceDir/log.html" "$OutputDir/all_log.html" -ErrorAction SilentlyContinue
        Copy-Item "$sourceDir/output.xml" "$OutputDir/all_output.xml" -ErrorAction SilentlyContinue
        Copy-Item "$sourceDir/report.html" "$OutputDir/all_report.html" -ErrorAction SilentlyContinue
    }
}

Write-Host "Tests completed!" -ForegroundColor Green
Write-Host "Results in: $OutputDir" -ForegroundColor Yellow
