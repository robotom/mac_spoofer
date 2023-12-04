#!/bin/bash

# Prompt for sudo password in terminal
sudo -v

# Check if sudo failed
if [ $? -ne 0 ]; then
    echo "Failed to obtain sudo privileges. Exiting."
    exit 1
fi

# Function to generate a random MAC address
generate_random_mac() {
    hexchars="0123456789ABCDEF"
    local mac="02" # Set the first byte to 02, which sets the local bit to 1 and multicast bit to 0
    for i in {1..5}; do
        mac="$mac:${hexchars:$(( $RANDOM % 16 )):1}${hexchars:$(( $RANDOM % 16 )):1}"
    done
    echo "$mac"
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
    sudo ip link set dev $interface down
    sleep 1

    echo "# Changing MAC address to $new_mac"
    sudo ip link set dev $interface address $new_mac
    sleep 1

    echo "# Enabling network interface $interface"
    sudo ip link set dev $interface up
    sleep 1

    echo "# MAC address spoofed successfully"
) | zenity --progress --title="MAC Spoofing in Progress" --text="Initializing..." --pulsate --auto-close

# Display the new MAC address
new_mac_confirmed=$(ip link show $interface | grep link/ether | awk '{print $2}')
zenity --info --title="MAC Address Spoofed" --text="New MAC address for $interface is $new_mac_confirmed"
