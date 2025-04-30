# Work Setup Script - README

## Description

This script sets up a complete development environment for NMKP (Norsk Medisinsk Kvalitetsregisterplattform) applications. It automatically opens multiple Konsole tabs with the correct working directories and launches your preferred IDE (Visual Studio Code or Haystack) with the appropriate projects.

## Prerequisites

- KDE Konsole terminal emulator
- qdbus command-line utility
- Optional: Visual Studio Code or Haystack IDE
- A proper NMKP workspace structure

## Installation

1. Save the script as work_setup.sh in your preferred location
2. Make it executable: `chmod +x work_setup.sh`
3. Customize the WORKSPACE_PATH variable in the script if necessary

## Usage

### Options

- `-h, --help`: Show the help message and exit

### Arguments

- `ide`: The IDE to use (vscode or haystack). Default: vscode

## Examples

```sh
# Use VSCode with default register
./work_setup.sh vscode

# Use Haystack with nmkp-test register
./work_setup.sh haystack
```

## Features

- Opens four Konsole tabs with appropriate working directories:
  1. NMKP main repository
  2. NMKP App Core module
  3. Fenestra root directory
  4. Fenestra frontend directory
- Sets descriptive titles for each Konsole tab
- Launches your preferred IDE with the relevant projects
- Closes the script's tab automatically when finished

### Customization

Edit the script to modify:

- Default register name
- IDE options
- Workspace paths
- Tab layout configuration
- Troubleshooting

If you encounter errors:

- Ensure Konsole and qdbus are installed
- Verify your workspace directory structure matches what the script expects
- Check that you have proper permissions for all directories
- Make sure your layout file exists at the specified location
