# Save Cursor Chat Sessions to Text Files
# This script extracts Cursor chat sessions and saves them to text files

# Configuration
$outputDir = ".\cursor_chats"
$cursorAppDataDir = "$env:APPDATA\Cursor"
$dateFormat = "yyyy-MM-dd_HH-mm-ss"

# Create output directory if it doesn't exist
if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Created directory: $outputDir"
}

# Function to extract chat data from Cursor's storage
function Get-CursorChats {
    # The exact location depends on Cursor's internal storage format
    # This function should be modified based on how Cursor actually stores chats
    
    # Example: If chats are stored in SQLite database
    # If you have sqlite3.exe in your PATH or specify its location:
    # & sqlite3.exe "$cursorAppDataDir\Local Storage\leveldb\cursor.db" "SELECT * FROM chats" -csv
    
    # Placeholder: For now, we'll just simulate with sample chat data
    # In a real implementation, you'd extract actual chat data
    
    $sampleChats = @(
        [PSCustomObject]@{
            ChatId = "chat_1"
            Title = "First Chat Session"
            Timestamp = (Get-Date).AddDays(-3)
            Messages = @(
                [PSCustomObject]@{Role = "user"; Content = "How do I create a PowerShell script?"}
                [PSCustomObject]@{Role = "assistant"; Content = "You can create a PowerShell script by creating a new file with a .ps1 extension..."}
            )
        },
        [PSCustomObject]@{
            ChatId = "chat_2"
            Title = "Code Review Session"
            Timestamp = (Get-Date).AddDays(-1)
            Messages = @(
                [PSCustomObject]@{Role = "user"; Content = "Can you review this code?"}
                [PSCustomObject]@{Role = "assistant"; Content = "I'd be happy to review your code. Let's analyze it..."}
                [PSCustomObject]@{Role = "user"; Content = "Thank you for the feedback."}
            )
        }
    )
    
    return $sampleChats
}

# Function to format chat for text file
function Format-ChatForExport {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Chat
    )
    
    $output = "# $($Chat.Title)`n"
    $output += "Date: $($Chat.Timestamp.ToString($dateFormat))`n"
    $output += "ID: $($Chat.ChatId)`n"
    $output += "-" * 50 + "`n`n"
    
    foreach ($message in $Chat.Messages) {
        $role = $message.Role.ToUpper()
        $content = $message.Content
        
        $output += "[$role]:`n$content`n`n"
    }
    
    return $output
}

# Main execution
try {
    Write-Host "Retrieving Cursor chat sessions..."
    $chats = Get-CursorChats
    
    Write-Host "Found $($chats.Count) chat sessions."
    
    foreach ($chat in $chats) {
        $chatContent = Format-ChatForExport -Chat $chat
        $filename = "$($chat.Timestamp.ToString($dateFormat))_$($chat.ChatId).txt"
        $filePath = Join-Path -Path $outputDir -ChildPath $filename
        
        $chatContent | Out-File -FilePath $filePath -Encoding utf8
        Write-Host "Saved chat '$($chat.Title)' to $filePath"
    }
    
    Write-Host "All chats have been saved to $outputDir"
}
catch {
    Write-Error "An error occurred: $_"
}

# Notes for implementation:
# 1. The actual location of Cursor chat data may vary based on version and platform
# 2. You may need to use specific tools or libraries to access Cursor's storage
# 3. For a complete implementation, you would need to understand Cursor's specific data structure
# 4. Consider adding command-line parameters for customization (output directory, filters, etc.)

# Usage information:
Write-Host "`nTo use this script:"
Write-Host "1. Run it directly in PowerShell: .\save_cursor_chats.ps1"
Write-Host "2. Chats will be saved to the '$outputDir' directory"
Write-Host "3. Edit the script variables at the top to customize behavior" 