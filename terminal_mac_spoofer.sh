#!/bin/bash

# Function to generate a random MAC address
generate_random_mac() {
    hexchars="0123456789ABCDEF"
    local mac="02" # Set the first byte to 02, which sets the local bit to 1 and multicast bit to 0
    for i in {1..5}; do
        mac="$mac:${hexchars:$(( $RANDOM % 16 )):1}${hexchars:$(( $RANDOM % 16 )):1}"
    done
    echo "$mac"
}


# List network interfaces
echo "Available network interfaces:"
ip link show | grep -E '^[0-9]+:' | awk -F: '{print $2}' | while read line; do
    echo "$line - $(ip link show $line | grep link/ether | awk '{print $2}')"
done

# Prompt user to choose a network interface
read -p "Enter the network interface you want to spoof (e.g., wlp0s20f3): " interface

# Generate a random MAC address
new_mac=$(generate_random_mac)
echo "Generated MAC address: $new_mac"

# Spoof the MAC address
sudo ip link set dev $interface down
sudo ip link set dev $interface address $new_mac
sudo ip link set dev $interface up

# Confirm the change
echo "New MAC address for $interface:"
ip link show $interface | grep link/ether | awk '{print $2}'
