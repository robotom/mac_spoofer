#!/bin/bash

# Function to generate a random MAC address
generate_random_mac() {
    hexchars="0123456789ABCDEF"
    echo "$(for i in {1..6}; do echo -n ${hexchars:$(( $RANDOM % 16 )):1}${hexchars:$(( $RANDOM % 16 )):1}; [ $i -lt 6 ] && echo -n ':'; done)"
}

# Get a list of network interfaces
interfaces=$(ip link show | grep -E '^[0-9]+:' | awk -F: '{print $2}')

# Create a selection menu for network interfaces
interface=$(zenity --list --title="Select Network Interface" --column="Network Interfaces" $interfaces)

# Check if user cancelled the operation
if [ -z "$interface" ]; then
    zenity --error --text="No interface selected. Exiting."
    exit 1
fi

# Ask the user to enter a MAC address or generate a random one
new_mac=$(zenity --entry --title="Enter MAC Address" --text="Enter a MAC address or leave blank for a random one:")

# Check if the MAC address is empty or invalid
if [ -z "$new_mac" ]; then
    new_mac=$(generate_random_mac)
elif ! [[ $new_mac =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
    zenity --error --text="Invalid MAC address format. Exiting."
    exit 1
fi

# Ask for sudo password
password=$(zenity --password --title="Authentication Required")

# Confirmation dialog
zenity --question --title="Confirm MAC Spoofing" --text="Spoof MAC address of $interface to $new_mac?\n\nThis action requires administrative privileges."

# If user cancels the confirmation
if [ $? -ne 0 ]; then
    zenity --info --text="MAC spoofing cancelled."
    exit 1
fi

# Execute the MAC spoofing
(
    echo "# Disabling network interface $interface" 
    echo $password | sudo -S ip link set dev $interface down
    sleep 1

    echo "# Changing MAC address to $new_mac"
    echo $password | sudo -S ip link set dev $interface address $new_mac
    sleep 1

    echo "# Enabling network interface $interface"
    echo $password | sudo -S ip link set dev $interface up
    sleep 1

    echo "# MAC address spoofed successfully"
) | zenity --progress --title="MAC Spoofing in Progress" --text="Initializing..." --pulsate --auto-close

# Display the new MAC address
new_mac_confirmed=$(ip link show $interface | grep link/ether | awk '{print $2}')
zenity --info --title="MAC Address Spoofed" --text="New MAC address for $interface is $new_mac_confirmed"
