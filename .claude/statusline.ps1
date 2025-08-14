# Claude Code StatusLine Script
# Shows useful system and development context

# Set UTF-8 encoding (suppress errors if not supported)
try { 
    $OutputEncoding = [System.Text.Encoding]::UTF8 
} catch { }

# Get current location
$location = (Get-Location).Path.Replace("C:\Users\josep\Documents\", "")

# Get git status if in a git repo
$gitInfo = ""
try {
    $gitBranch = git branch --show-current 2>$null
    if ($gitBranch) {
        $gitStatus = git status --porcelain 2>$null
        $changes = if ($gitStatus) { " (~)" } else { "" }
        $gitInfo = " | git:$gitBranch$changes"
    }
} catch {}

# Get system info
$cpuUsage = (Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
$memInfo = Get-CimInstance Win32_OperatingSystem
$memUsed = [math]::Round(($memInfo.TotalVisibleMemorySize - $memInfo.FreePhysicalMemory) / 1MB, 1)
$memTotal = [math]::Round($memInfo.TotalVisibleMemorySize / 1MB, 1)

# Get network info
$networkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Name -match "(Ethernet|Wi-Fi)"} | Select-Object -First 1
$networkName = if ($networkAdapter) { $networkAdapter.Name } else { "Offline" }

# Get time
$time = Get-Date -Format "HH:mm:ss"

# Output status line
Write-Output "DIR: $location$gitInfo | CPU: $([math]::Round($cpuUsage, 0))% | RAM: $memUsed/$memTotal GB | NET: $networkName | TIME: $time"