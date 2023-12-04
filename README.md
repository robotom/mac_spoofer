# mac_spoofer

<p align="center">    <img src="other/gui_demo.gif" alt="GUI Demo" width="400">
</p>

### Why spoof your MAC? 

I was staying in a hotel and connected to the wifi. I got one of those one-time login page when conecting. I forgot to put the promo code in. Then I got stuck with 4Mbit/s and not the faster promo speed. I wasn't able to return to the login page, nor was I able to bring it back up by clearing cookies, deleting the connection, using a different browser, etc. I suppose the hotel network remembers the device based on its MAC address which then makes you automatically bypass the login page. 

### The fix

The solution involves temporarily changing the device's MAC address. This makes the network treat the device as a new entity, thereby prompting the login page again.

### Tested on my system 

- Ubunu 20.04
- Lenovo Thinkpad
- Wireless connection

## Manual instructions

**Also worth noting that this is pretty much what is happening in the automated scripts that I have created below.**

Open your terminal... 

### 1. Disable the Network Interface

Identify your Wi-Fi network interface using ifconfig or ip link show. Then, disable it using: `sudo ip link set dev [interface_name] down`. 

Replace `[interface_name]` with your actual Wi-Fi interface name. In my case it was `wlp0s20f3`.

### 2. Change the MAC Address

Generate a new MAC address or use a specific one, then apply it: `sudo ip link set dev [interface_name] address XX:XX:XX:XX:XX:XX`.

#### MAC address rules: 

**General:**

    The maximum length of a MAC address is 17 characters. MAC addresses are composed of the following characters: "0-9", "a-f", "A-F", and ":". MAC addresses must be in the following format: xx:xx:xx:xx.
    A MAC address consists of 48 bits, usually represented as a string of 12 hexadecimal digits (0 to 9, a to f, or A to F); these are often grouped into pairs separated by colons or dashes. For example, the MAC address 001B638445E6 may be given as 00:1b:63:84:45:e6 or as 00-1B-63-84-45-E6.

**Advanced:**

When setting randomly generated MAC addresses, I kept getting this error: `RTNETLINK answers: Cannot assign requested address`. I guess I should have done some more extensive reading on MAC addresses. Thank you GPT4. 

    "Understanding the significance of the bits in a MAC address is crucial for correctly setting a custom MAC address.

    Multicast Bit: The least significant bit of the first byte of the MAC address is the multicast bit. If this bit is set to 1, the address is treated as a multicast address, which is not suitable for a device's unique identifier.

    Local Assignment Bit: The second least significant bit in the first byte of the MAC address is the local assignment bit. When setting a custom MAC address, this bit should be set to 1 to indicate that the address is locally administered and not assigned by a hardware manufacturer.

    In the example you provided (21:87:ac:b3:7d:66), the first byte 21 in binary is 00100001. Here, the multicast bit is 0 (which is correct), but the local assignment bit is also 0 (which should ideally be 1 for custom MAC addresses).

    To correct this, you should ensure that the second least significant bit of the first byte is set to 1. For example, you could use 22:87:ac:b3:7d:66 or 26:87:ac:b3:7d:66 (where 22 and 26 in binary are 00100010 and 00100110, respectively, both having the local bit set to 1)."

### 3. Re-enable the Network Interface

Run: `sudo ip link set dev [interface_name] up`.

### 4. Verify the New MAC Address

Run: `ip link show [interface_name]`.

### 5. Notes

- This change is temporary. The MAC address reverts to its original state after a system reboot.
- If any issues arise, simply reboot your device to revert to the original MAC address.

## Automated one-time-use script 

### Features

- Displays all network interfaces along with their current MAC addresses.
- Allows you to choose the network interface you want to spoof.
- Automatically generates a random, valid MAC address.

### Using the Script

To run: `./terminal_mac_spoofer.sh`

- You will be asked for sudo privileges. 
- You will be asked to specify which network interface you'd like to spoof. 
- Done. 


## New MAC at every startup script

### Cron Job 

This is the easiest way to do it. I don't know if it's the most efficient. For example, what if your network device connects to the network somehow before this Job is executed. I haven't thought hard enough about this. Nevertheless...

1. Store the spoofing script somewhere safe. 
2. Open your crontab file with the command: `crontab -e` 
3. In the crontab file, add the following line: `@reboot /path/to/mac_spoof.sh`
4. Reboot and check by running: `ip link show [interface_name]`.
5. Should be spoofed.  

## GUI 

### Requirements

**Install**
- Zenity: `sudo apt-get install zenity`
    - For Shell GUI

### Using the GUI

It's easy to use. Just run it and follow the instructions: `./gui_mac_spoofer.sh`

- You can select a network interface from a list. I pick my wireless one. 
- You can enter a specific MAC address or leave it blank for a random one.
- A progress bar shows the process of disabling, changing the MAC address, and re-enabling the network interface.
- You should see a confirmation message with the new MAC address.

## Other Notes 

#### `[solved]` RTNETLINK error

I kept getting this error but eventually I got rid of it (GPT4 did actually..). See the MAC rules earlier in the readme. Hopefully it doesn't pop up again. 
