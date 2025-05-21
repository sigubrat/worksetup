#!/usr/bin/env bash
# Description: Sets up a work environment for developing NMKP applications using haystack or vscode
# Author: Sigurd Brattland
# Arguments: 
# 1. <vscode|haystack> - The IDE to use
# 2. <register_name> - The name of the register (default: nmkp-soreg)

IDE="vscode"

# Check for required commands
if ! command -v qdbus &> /dev/null || ! command -v konsole &> /dev/null; then
    echo "Error: Required commands 'qdbus' or 'konsole' are not available."
    exit 1
fi

# Validate IDE argument
if [ -n "$1" ] && [ "$1" != "vscode" ] && [ "$1" != "haystack" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
    echo "Error: Unsupported IDE '$1'. Supported options are 'vscode' or 'haystack'."
    exit 1
fi


# Help function
show_help() {
    echo "Usage: $(basename "$0") [options] [ide] [register_name]"
    echo
    echo "Sets up a work environment for developing NMKP applications"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo
    echo "Arguments:"
    echo "  ide             The IDE to use (vscode or haystack), default: vscode"
    echo
    echo "Examples:"
    echo "  $(basename "$0") vscode              # Use VSCode with default register"
    exit 0
}

# Check for help option
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
fi

if [ "$1" == "vscode" ]; then
    IDE="vscode"
elif [ "$1" == "haystack" ]; then
    IDE="haystack"
fi

# Replace workspace path with your own
WORKSPACE_PATH="/home/dev/Projects/workspace"
nmkp="cd $WORKSPACE_PATH/kvalreg-nmkp"
nmkpappcore="cd $WORKSPACE_PATH/kvalreg-nmkp/modules/nmkp-app-core"
register="cd $WORKSPACE_PATH/kvalreg-nmkp/modules/nmkp-fenestra"
registerfrontend="cd $WORKSPACE_PATH/kvalreg-nmkp/modules/nmkp-fenestra/frontend"


konsole --hold --layout nmkp-tabs-layout.json & KPID=$!

sleep 0.5

service="$(qdbus | grep -B1 konsole | grep -v -- -- | sort -t"." -k2 -n | tail -n 1)"

# Run commands in new tabs
qdbus $service /Sessions/1 org.kde.konsole.Session.runCommand "${nmkp}"
qdbus $service /Sessions/2 org.kde.konsole.Session.runCommand "${nmkpappcore}"
qdbus $service /Sessions/3 org.kde.konsole.Session.runCommand "${register}"
qdbus $service /Sessions/4 org.kde.konsole.Session.runCommand "${registerfrontend}"

# Set tab titles
qdbus $service /Sessions/1 setTitle 1 'NMKP'
qdbus $service /Sessions/2 setTitle 1 'NMKP App Core'
qdbus $service /Sessions/3 setTitle 1 "Fenestra"
qdbus $service /Sessions/4 setTitle 1 "Fenestra frontend"


# Open up IDE of choice 
if [ "$IDE" == "haystack" ]; then
    konsole --new-tab --hold --workdir /home/dev/Downloads -e "nix-shell -p appimage-run"
fi

if [ "$IDE" == "vscode" ]; then
    # Open VSCode instances in new konsole tabs
    konsole --new-tab --workdir /home/dev/Projects/workspace/kvalreg-nmkp -e "code ."
fi


# Close the current tab when script completes
if [ -n "$KONSOLE_DBUS_SESSION" ]; then

    (
        sleep 3
        qdbus $KONSOLE_DBUS_SERVICE $KONSOLE_DBUS_SESSION org.kde.konsole.Session.sendText "exit"
        qdbus $KONSOLE_DBUS_SERVICE $KONSOLE_DBUS_SESSION org.kde.konsole.Session.sendText $'\r'
    ) &
else
    # For generic terminal behavior when not in Konsole
    echo "Script completed. Tab will remain open."
fi

exit 0