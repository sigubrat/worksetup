#!/usr/bin/env bash
# Description: Sets up a work environment for developing NMKP applications using haystack or vscode
# Author: Sigurd Brattland
# Arguments: 
# 1. <vscode|haystack> - The IDE to use
# 2. <register_name> - The name of the register (default: nmkp-soreg)

# defaults
REGISTER_NAME="nmkp-soreg"
IDE="vscode"

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
    echo "  register_name   The name of the register, default: nmkp-soreg"
    echo
    echo "Examples:"
    echo "  $(basename "$0") vscode              # Use VSCode with default register"
    echo "  $(basename "$0") haystack nmkp-test  # Use Haystack with nmkp-test register"
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

if [ "$2" ]; then
    REGISTER_NAME=$2
fi

nmkp="cd /home/dev/Projects/workspace/kvalreg-nmkp"
nmkpappcore="cd /home/dev/Projects/workspace/kvalreg-nmkp/modules/nmkp-app-core"
register="cd /home/dev/Projects/workspace/$REGISTER_NAME"
registerfrontend="cd /home/dev/Projects/workspace/$REGISTER_NAME/frontend"

konsole --hold --layout $HOME/nmkp-tabs-layout.json & KPID=$!

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
qdbus $service /Sessions/3 setTitle 1 "$REGISTER_NAME"
qdbus $service /Sessions/4 setTitle 1 "$REGISTER_NAME frontend"


# Open up IDE of choice 
if [ "$IDE" == "haystack" ]; then
    konsole --new-tab --hold --workdir /home/dev/Downloads -e "nix-shell -p appimage-run"
fi

if [ "$IDE" == "vscode" ]; then
    # Open VSCode instances in new konsole tabs
    konsole --new-tab --workdir /home/dev/Projects/workspace/kvalreg-nmkp -e "code ."
    konsole --new-tab --workdir /home/dev/Projects/workspace/$REGISTER_NAME -e "code ."
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