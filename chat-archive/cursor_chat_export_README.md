# Cursor Chat Export Tools

This repository contains PowerShell scripts designed to export your Cursor AI chat history to text files.

## Scripts Included

1. **save_cursor_chats.ps1** - A basic script with sample data for demonstration purposes
2. **export_cursor_chats.ps1** - An advanced script that attempts to locate and extract real Cursor chat data
3. **export_cursor_leveldb.ps1** - A specialized script focusing on extracting data from Cursor's LevelDB storage format
4. **extract_cursor_logs.ps1** - A simple script for extracting readable text from LevelDB log files

## How to Use

### Basic Export (Sample Data)

To run the basic script with sample data:

```powershell
.\save_cursor_chats.ps1
```

This will:
- Create a `cursor_chats` directory in the current location
- Generate text files with sample chat data
- Display information about the process

### Advanced Export (Real Data)

To attempt to extract and export your actual Cursor chat history:

```powershell
.\export_cursor_chats.ps1
```

For more detailed output during processing:

```powershell
.\export_cursor_chats.ps1 -Verbose
```

To save chats to a custom directory:

```powershell
.\export_cursor_chats.ps1 -OutputDirectory "C:\Path\To\ExportFolder"
```

To force generation of sample data even if real data is found:

```powershell
.\export_cursor_chats.ps1 -Force
```

### LevelDB-Specific Export

For direct extraction from Cursor's LevelDB storage:

```powershell
.\export_cursor_leveldb.ps1
```

This script:
- Focuses specifically on LevelDB files in Cursor's data directory
- Attempts to extract and analyze the contents for chat data
- Can copy the raw LevelDB files for later analysis with specialized tools
- Requires LevelDB tools for full extraction capabilities

Custom LevelDB path:
```powershell
.\export_cursor_leveldb.ps1 -LevelDBPath "C:\Path\To\Cursor\LevelDB"
```

### Log File Extraction

To extract readable text from LevelDB log files:

```powershell
.\extract_cursor_logs.ps1
```

This script:
- Reads LevelDB log files and extracts any readable text
- Formats the content for easy viewing in a markdown format
- Identifies potential chat-related keywords
- Creates a comprehensive report file

## About Cursor Chat Data

Cursor's chat data storage is not officially documented, so these scripts attempt to locate and extract data from several possible locations:

- `%APPDATA%\Cursor`
- `%LOCALAPPDATA%\Cursor`
- `%USERPROFILE%\.cursor`

The scripts look for potential data storage in:
- SQLite databases
- JSON files with chat-related names
- LevelDB directories (primary storage mechanism)

## Key Findings

Our investigation has found that:

1. Cursor primarily uses LevelDB for data storage
2. The main LevelDB directory is typically at: `%APPDATA%\Cursor\Local Storage\leveldb`
3. The actual chat data is likely stored in other locations beyond the basic LevelDB files
4. The LevelDB files contain references to user data but may not contain the actual chat content
5. More specialized tools may be needed for full extraction of the chat history

## LevelDB Extraction Requirements

The `export_cursor_leveldb.ps1` script works best with LevelDB extraction tools:

- **leveldb-dump**: Available via npm (`npm install -g leveldb-dump`)
- **Google LevelDB tools**: Compiled from source

Without these tools, the script will still copy raw LevelDB files for manual inspection or later processing.

## Output Format

Each chat is saved as a text file with the following format:

```
# Chat Title
Date: YYYY-MM-DD_HH-MM-SS
Source: [data source]
--------------------------------------------------

[USER]:
User message content

[ASSISTANT]:
AI response content

...
```

## Requirements

- Windows with PowerShell
- For advanced SQLite database access (if found), the SQLite command-line tool (`sqlite3.exe`) must be in your PATH
- For LevelDB extraction, LevelDB tools are recommended

## Limitations

- These scripts provide a best-effort approach to exporting chat data
- The actual data structure of Cursor chats may vary by version
- Some data formats (like LevelDB) require specialized tools for direct access
- If no actual chat data is found, sample data will be generated for demonstration

## Advanced Usage

You can modify the scripts to customize how chat data is extracted, formatted, and saved. The key areas to customize:

- In `Find-CursorDataFiles`: Add additional search locations
- In `Extract-ChatsFromDataFiles`: Implement specific extraction logic for your Cursor version 
- In `Save-ChatToFile`: Customize the output format

## Future Improvements

1. Add support for ExtractingJSON data from IndexedDB directories
2. Implement more sophisticated analysis of LevelDB binary data
3. Add browser history integration to correlate chats with browser usage
4. Develop a tool to monitor and capture chats in real-time

## License

These scripts are provided as-is for personal use. 