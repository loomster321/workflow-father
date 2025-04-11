# Extract Cursor LevelDB Log Files
# This script attempts to extract readable text from LevelDB log files

param (
    [string]$LogDir = ".\cursor_chats_leveldb\leveldb_backup_2025-04-10_12-05-15",
    [string]$OutputFile = ".\cursor_extracted_logs.txt"
)

if (-not (Test-Path -Path $LogDir)) {
    Write-Host "Log directory not found: $LogDir" -ForegroundColor Red
    exit 1
}

Write-Host "Extracting readable text from LevelDB log files in: $LogDir" -ForegroundColor Cyan

$logFilePatterns = @("*.log", "LOG", "LOG.old")
$outputContent = "# Cursor LevelDB Log Extraction`n"
$outputContent += "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$outputContent += "Source: $LogDir`n"
$outputContent += "-" * 50 + "`n`n"

foreach ($pattern in $logFilePatterns) {
    $logFiles = Get-ChildItem -Path $LogDir -Filter $pattern
    
    foreach ($logFile in $logFiles) {
        $outputContent += "### File: $($logFile.Name) ($($logFile.Length) bytes)`n"
        
        try {
            # Try to read as text
            $fileContent = Get-Content -Path $logFile.FullName -Raw -ErrorAction SilentlyContinue
            
            if ($fileContent) {
                # Look for readable text patterns in the content
                $readableContent = $fileContent -replace '[^\x20-\x7E\r\n]', '.'
                
                $outputContent += "```````n"
                $outputContent += $readableContent
                $outputContent += "`n``````n`n"
                
                # Look for potential chat-related content
                $chatKeywords = @("message", "chat", "conversation", "user", "assistant", "human", "ai", "claude", "cursor")
                $foundKeywords = @()
                
                foreach ($keyword in $chatKeywords) {
                    if ($readableContent -match $keyword) {
                        $foundKeywords += $keyword
                    }
                }
                
                if ($foundKeywords.Count -gt 0) {
                    $outputContent += "**Found potential chat keywords:** $($foundKeywords -join ', ')`n`n"
                }
            }
            else {
                $outputContent += "Binary content - could not read as text`n`n"
                
                # Try to output hex dump for analysis
                $hexDump = [System.BitConverter]::ToString((Get-Content -Path $logFile.FullName -Encoding Byte -ReadCount 0))
                $outputContent += "First 200 bytes (hex):`n"
                $outputContent += $hexDump.Substring(0, [Math]::Min(600, $hexDump.Length)) + "...`n`n"
            }
        }
        catch {
            $outputContent += "Error reading file: $_`n`n"
        }
        
        $outputContent += "-" * 50 + "`n`n"
    }
}

# Save the extracted content
$outputContent | Out-File -FilePath $OutputFile -Encoding utf8
Write-Host "Extracted log content saved to: $OutputFile" -ForegroundColor Green

# Open the file for viewing
Write-Host "Opening extracted log file..." -ForegroundColor Cyan
Invoke-Item $OutputFile 