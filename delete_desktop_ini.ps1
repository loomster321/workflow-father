# Script to delete all desktop.ini files in .git directory and subdirectories
Get-ChildItem -Path ".\.git" -Filter 'desktop.ini' -Recurse -File -Force | Remove-Item -Force

Write-Output "All desktop.ini files have been deleted from .git and its subdirectories." 