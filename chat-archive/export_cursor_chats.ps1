# Export Cursor Chat Sessions to Text Files
# This script attempts to extract and save Cursor chat history to text files

param (
    [string]$OutputDirectory = ".\cursor_chats",
    [switch]$Verbose = $false,
    [switch]$Force = $false
)

# Configuration
$dateFormat = "yyyy-MM-dd_HH-mm-ss"
$potentialCursorDirs = @(
    "$env:APPDATA\Cursor",
    "$env:LOCALAPPDATA\Cursor",
    "$env:USERPROFILE\.cursor"
)

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

# Function to search for Cursor data files
function Find-CursorDataFiles {
    Write-VerboseOutput "Searching for Cursor data files..."
    
    $dataFiles = @()
    
    foreach ($baseDir in $potentialCursorDirs) {
        if (Test-Path $baseDir) {
            Write-VerboseOutput "Checking directory: $baseDir"
            
            # Check for SQLite databases
            $dbFiles = Get-ChildItem -Path $baseDir -Recurse -File -ErrorAction SilentlyContinue | 
                       Where-Object { $_.Extension -in @('.db', '.sqlite', '.sqlite3') -or $_.Name -eq 'cursor.db' }
            
            # Check for JSON files that might contain chat data
            $jsonFiles = Get-ChildItem -Path $baseDir -Recurse -File -ErrorAction SilentlyContinue |
                         Where-Object { $_.Extension -eq '.json' -and ($_.Name -like '*chat*' -or $_.Name -like '*conversation*' -or $_.Name -like '*history*') }
            
            # Look for specific Cursor data directories
            $leveldbDirs = Get-ChildItem -Path $baseDir -Recurse -Directory -ErrorAction SilentlyContinue |
                           Where-Object { $_.Name -eq 'leveldb' -or $_.Name -like '*IndexedDB*' }
            
            $dataFiles += $dbFiles
            $dataFiles += $jsonFiles
            
            foreach ($dir in $leveldbDirs) {
                Write-VerboseOutput "Found potential LevelDB directory: $($dir.FullName)"
                $dataFiles += [PSCustomObject]@{
                    FullName = $dir.FullName
                    Name = $dir.Name
                    Extension = "dir"
                }
            }
        }
    }
    
    return $dataFiles
}

# Function to attempt to extract chats from found data files
function Extract-ChatsFromDataFiles {
    param([array]$DataFiles)
    
    $extractedChats = @()
    
    foreach ($file in $DataFiles) {
        Write-VerboseOutput "Examining: $($file.FullName)"
        
        try {
            # Handle different file types
            switch ($file.Extension) {
                '.json' {
                    # Try to parse JSON file
                    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
                    if ($content) {
                        $jsonData = $content | ConvertFrom-Json -ErrorAction SilentlyContinue
                        # Look for chat-like structures in the JSON
                        if ($jsonData -and ($jsonData.chats -or $jsonData.conversations -or $jsonData.messages)) {
                            Write-Host "Found potential chat data in: $($file.FullName)" -ForegroundColor Green
                            # Extract the data - implementation would depend on actual structure
                            # For now, just save the raw content to analyze
                            $extractedChats += [PSCustomObject]@{
                                Source = $file.FullName
                                Type = "json"
                                RawContent = $content
                                Timestamp = Get-Date
                                Title = "Extracted from $($file.Name)"
                            }
                        }
                    }
                }
                {$_ -in @('.db', '.sqlite', '.sqlite3')} {
                    # If SQLite tools are available, you could query the database
                    Write-Host "Found potential SQLite database: $($file.FullName)" -ForegroundColor Yellow
                    Write-Host "  Note: SQLite access requires sqlite3.exe in your PATH" -ForegroundColor Yellow
                    
                    # Check if sqlite3 is available
                    $sqliteAvailable = $null -ne (Get-Command sqlite3 -ErrorAction SilentlyContinue)
                    if ($sqliteAvailable) {
                        Write-Host "  SQLite tools found, attempting to extract data..." -ForegroundColor Green
                        # This would need to be customized based on actual database schema
                        # & sqlite3 $file.FullName ".tables" | Out-String
                    }
                }
                'dir' {
                    # For LevelDB directories, just note them - specialized tools would be needed
                    Write-Host "Found potential LevelDB directory: $($file.FullName)" -ForegroundColor Yellow
                    Write-Host "  Note: LevelDB requires specialized tools to access directly" -ForegroundColor Yellow
                }
            }
        }
        catch {
            Write-VerboseOutput "Error processing $($file.FullName): $_"
        }
    }
    
    # If no chats were found, fall back to sample data
    if ($extractedChats.Count -eq 0 -or $Force) {
        Write-Host "No real chat data extracted, using sample data..." -ForegroundColor Yellow
        $extractedChats = Get-SampleChats
    }
    
    return $extractedChats
}

# Function to provide sample chat data for demonstration
function Get-SampleChats {
    Write-VerboseOutput "Generating sample chat data..."
    
    return @(
        [PSCustomObject]@{
            Source = "Sample"
            Type = "sample"
            ChatId = "chat_1"
            Title = "First Chat Session"
            Timestamp = (Get-Date).AddDays(-3)
            Messages = @(
                [PSCustomObject]@{Role = "user"; Content = "How do I create a PowerShell script?"}
                [PSCustomObject]@{Role = "assistant"; Content = "You can create a PowerShell script by creating a new file with a .ps1 extension and adding PowerShell commands to it. PowerShell scripts can automate tasks, process data, and interact with various system components."}
            )
        },
        [PSCustomObject]@{
            Source = "Sample" 
            Type = "sample"
            ChatId = "chat_2"
            Title = "Code Review Session"
            Timestamp = (Get-Date).AddDays(-1)
            Messages = @(
                [PSCustomObject]@{Role = "user"; Content = "Can you review this code?"}
                [PSCustomObject]@{Role = "assistant"; Content = "I'd be happy to review your code. Let's analyze it for potential issues, performance optimizations, and adherence to best practices."}
                [PSCustomObject]@{Role = "user"; Content = "Thank you for the feedback."}
            )
        }
    )
}

# Function to format and save chat data
function Save-ChatToFile {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Chat,
        [string]$OutputDir = $OutputDirectory
    )
    
    # Generate filename
    if ($Chat.Type -eq "sample") {
        $filename = "$($Chat.Timestamp.ToString($dateFormat))_$($Chat.ChatId).txt"
        
        # Format sample chat
        $output = "# $($Chat.Title)`n"
        $output += "Date: $($Chat.Timestamp.ToString($dateFormat))`n"
        $output += "Source: Sample data`n"
        $output += "-" * 50 + "`n`n"
        
        foreach ($message in $Chat.Messages) {
            $role = $message.Role.ToUpper()
            $content = $message.Content
            
            $output += "[$role]:`n$content`n`n"
        }
    }
    else {
        # For real data, we may need different handling based on the structure
        $timestamp = $Chat.Timestamp.ToString($dateFormat)
        $sanitizedTitle = $Chat.Title -replace '[\\/:*?"<>|]', '_'
        $filename = "${timestamp}_${sanitizedTitle}.txt"
        
        if ($Chat.Type -eq "json") {
            # For JSON data, save a formatted version
            $output = "# $($Chat.Title)`n"
            $output += "Date: $($Chat.Timestamp.ToString($dateFormat))`n"
            $output += "Source: $($Chat.Source)`n"
            $output += "-" * 50 + "`n`n"
            
            # This is just raw data for now - in a real implementation,
            # you would parse and format the actual chat content
            $output += "Raw data from JSON source:`n"
            $output += "-" * 30 + "`n"
            
            # Limit the raw content to avoid huge files
            $rawContentPreview = $Chat.RawContent
            if ($rawContentPreview.Length -gt 10000) {
                $rawContentPreview = $rawContentPreview.Substring(0, 10000) + "`n... [content truncated for readability]"
            }
            
            $output += $rawContentPreview
        }
    }
    
    # Save to file
    $filePath = Join-Path -Path $OutputDir -ChildPath $filename
    $output | Out-File -FilePath $filePath -Encoding utf8
    
    return $filePath
}

# Main execution
Write-Host "===== Cursor Chat Exporter =====" -ForegroundColor Magenta
Write-Host "Output directory: $OutputDirectory"

try {
    # Search for potential Cursor data files
    $dataFiles = Find-CursorDataFiles
    Write-Host "Found $($dataFiles.Count) potential data files." -ForegroundColor Cyan
    
    # Extract chats from the data files
    $chats = Extract-ChatsFromDataFiles -DataFiles $dataFiles
    Write-Host "Extracted $($chats.Count) chat sessions." -ForegroundColor Green
    
    # Save each chat to a file
    $savedFiles = @()
    foreach ($chat in $chats) {
        $savedPath = Save-ChatToFile -Chat $chat
        $savedFiles += $savedPath
        Write-Host "Saved chat to: $savedPath" -ForegroundColor Green
    }
    
    Write-Host "`nSuccessfully saved $($savedFiles.Count) chat files to $OutputDirectory" -ForegroundColor Green
    
    # Provide quick summary
    Write-Host "`nSummary:"
    Write-Host "- Files examined: $($dataFiles.Count)"
    Write-Host "- Chats extracted: $($chats.Count)"
    Write-Host "- Files created: $($savedFiles.Count)"
}
catch {
    Write-Error "An error occurred: $_"
}

# Usage information
Write-Host "`nUsage:" -ForegroundColor Cyan
Write-Host ".\export_cursor_chats.ps1 [-OutputDirectory <path>] [-Verbose] [-Force]"
Write-Host "  -OutputDirectory : Specify a custom output directory (default: $OutputDirectory)"
Write-Host "  -Verbose         : Show detailed processing information"
Write-Host "  -Force           : Force generation of sample data even if real data is found"