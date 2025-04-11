# Export Cursor Chats from LevelDB
# This script focuses on extracting Cursor chat data from LevelDB storage

param (
    [string]$OutputDirectory = ".\cursor_chats_leveldb",
    [switch]$Verbose = $false,
    [string]$LevelDBPath = "$env:APPDATA\Cursor\Local Storage\leveldb"
)

# Configuration
$dateFormat = "yyyy-MM-dd_HH-mm-ss"

# Function to write verbose output
function Write-VerboseOutput {
    param([string]$Message)
    if ($Verbose) {
        Write-Host $Message -ForegroundColor Cyan
    }
}

# Create output directory if it doesn't exist
if (-not (Test-Path -Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
    Write-Host "Created directory: $OutputDirectory"
}

# Check if LevelDB path exists
if (-not (Test-Path -Path $LevelDBPath)) {
    Write-Host "LevelDB path not found: $LevelDBPath" -ForegroundColor Red
    Write-Host "Please specify a valid LevelDB path." -ForegroundColor Red
    Write-Host "Common locations:"
    Write-Host "  - $env:APPDATA\Cursor\Local Storage\leveldb"
    Write-Host "  - $env:LOCALAPPDATA\Cursor\Local Storage\leveldb"
    Write-Host "  - $env:USERPROFILE\.cursor\Local Storage\leveldb"
    exit 1
}

# List LevelDB files for inspection
Write-Host "Found LevelDB directory: $LevelDBPath" -ForegroundColor Green
$leveldbFiles = Get-ChildItem -Path $LevelDBPath -File
Write-Host "Files in LevelDB directory:" -ForegroundColor Cyan
foreach ($file in $leveldbFiles) {
    Write-Host "  - $($file.Name) ($($file.Length) bytes)"
}

# Function to attempt to extract chat data from LevelDB files
function Extract-ChatDataFromLevelDB {
    param(
        [string]$LevelDBDirectory = $LevelDBPath
    )
    
    Write-Host "Attempting to extract chat data from LevelDB files..." -ForegroundColor Yellow
    
    # Check for LevelDB extraction tools
    $levelDBExporter = $null
    if (Get-Command leveldb-dump -ErrorAction SilentlyContinue) {
        $levelDBExporter = "leveldb-dump"
    }
    elseif (Get-Command leveldb_dump -ErrorAction SilentlyContinue) {
        $levelDBExporter = "leveldb_dump"
    }
    
    if ($levelDBExporter) {
        Write-Host "Found LevelDB extraction tool: $levelDBExporter" -ForegroundColor Green
        
        # Create a temporary directory for raw extraction
        $tempDir = Join-Path -Path $OutputDirectory -ChildPath "temp_leveldb_raw"
        if (-not (Test-Path -Path $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir | Out-Null
        }
        
        # Export raw data from LevelDB
        $rawOutputFile = Join-Path -Path $tempDir -ChildPath "leveldb_dump.txt"
        Write-Host "Exporting raw LevelDB data to: $rawOutputFile" -ForegroundColor Cyan
        try {
            & $levelDBExporter $LevelDBDirectory > $rawOutputFile
            Write-Host "LevelDB data exported successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Error exporting LevelDB data: $_" -ForegroundColor Red
        }
        
        # Analyze exported data for potential chat content
        if (Test-Path -Path $rawOutputFile) {
            Write-Host "Analyzing exported data for chat content..." -ForegroundColor Cyan
            $rawContent = Get-Content -Path $rawOutputFile -Raw
            
            # Look for patterns that might indicate chat data
            $chatPatterns = @(
                "conversation",
                "chat",
                "message",
                "user:",
                "assistant:",
                "human:",
                "ai:",
                "claude",
                "cursor"
            )
            
            $foundMatches = @()
            foreach ($pattern in $chatPatterns) {
                if ($rawContent -match $pattern) {
                    $foundMatches += $pattern
                }
            }
            
            if ($foundMatches.Count -gt 0) {
                Write-Host "Found potential chat data with patterns: $($foundMatches -join ', ')" -ForegroundColor Green
                
                # Save the content with potential chat data
                $chatDataFile = Join-Path -Path $OutputDirectory -ChildPath "cursor_leveldb_$(Get-Date -Format $dateFormat).txt"
                $rawContent | Out-File -FilePath $chatDataFile -Encoding utf8
                Write-Host "Saved potential chat data to: $chatDataFile" -ForegroundColor Green
                
                return $chatDataFile
            }
            else {
                Write-Host "No obvious chat patterns found in the exported data." -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "No LevelDB extraction tools found." -ForegroundColor Red
        Write-Host "To extract data from LevelDB, you need to install one of these tools:" -ForegroundColor Yellow
        Write-Host "  - leveldb-dump (available via npm: npm install -g leveldb-dump)" -ForegroundColor Yellow
        Write-Host "  - Google LevelDB tools (compile from source)" -ForegroundColor Yellow
        
        # Alternative approach: Just copy the raw LevelDB files
        $backupDir = Join-Path -Path $OutputDirectory -ChildPath "leveldb_backup_$(Get-Date -Format $dateFormat)"
        if (-not (Test-Path -Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir | Out-Null
        }
        
        Write-Host "Copying raw LevelDB files to: $backupDir" -ForegroundColor Cyan
        Copy-Item -Path "$LevelDBDirectory\*" -Destination $backupDir -Recurse
        Write-Host "Copied raw LevelDB files for future extraction." -ForegroundColor Green
        
        return $null
    }
    
    # Create raw dump of log files which might contain plain text
    $logFiles = Get-ChildItem -Path $LevelDBDirectory -Filter "*.log"
    if ($logFiles.Count -gt 0) {
        Write-Host "Found $($logFiles.Count) log files. Extracting contents..." -ForegroundColor Cyan
        $logOutputFile = Join-Path -Path $OutputDirectory -ChildPath "leveldb_logs_$(Get-Date -Format $dateFormat).txt"
        $logContent = ""
        
        foreach ($logFile in $logFiles) {
            $logContent += "=== $($logFile.Name) ===`n"
            try {
                $fileContent = Get-Content -Path $logFile.FullName -Raw -ErrorAction SilentlyContinue
                if ($fileContent) {
                    $logContent += $fileContent
                }
                else {
                    $logContent += "[Binary content - could not read as text]`n"
                }
            }
            catch {
                $logContent += "[Error reading file: $_]`n"
            }
            $logContent += "`n=== End of $($logFile.Name) ===`n`n"
        }
        
        $logContent | Out-File -FilePath $logOutputFile -Encoding utf8
        Write-Host "Saved log file contents to: $logOutputFile" -ForegroundColor Green
        
        return $logOutputFile
    }
    
    Write-Host "Could not extract chat data from LevelDB." -ForegroundColor Red
    return $null
}

# Main execution
Write-Host "===== Cursor LevelDB Chat Extractor =====" -ForegroundColor Magenta

try {
    $extractedFile = Extract-ChatDataFromLevelDB
    
    if ($extractedFile) {
        Write-Host "`nPotential chat data was extracted to: $extractedFile" -ForegroundColor Green
        Write-Host "You can open this file in a text editor to search for chat content." -ForegroundColor Cyan
    }
    else {
        Write-Host "`nCould not extract chat data." -ForegroundColor Red
    }
    
    Write-Host "`nLevelDB extraction completed. Check $OutputDirectory for results." -ForegroundColor Green
    
    # Additional information
    Write-Host "`nNote: LevelDB format is complex and may require specialized tools for proper extraction." -ForegroundColor Yellow
    Write-Host "The raw files have been copied to allow for future extraction with appropriate tools." -ForegroundColor Yellow
}
catch {
    Write-Error "An error occurred: $_"
}

# Usage information
Write-Host "`nUsage:" -ForegroundColor Cyan
Write-Host ".\export_cursor_leveldb.ps1 [-OutputDirectory <path>] [-Verbose] [-LevelDBPath <path>]"
Write-Host "  -OutputDirectory : Specify output directory (default: $OutputDirectory)"
Write-Host "  -Verbose         : Show detailed processing information"
Write-Host "  -LevelDBPath     : Specify LevelDB directory path" 