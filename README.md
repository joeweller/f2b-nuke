# f2b-nuke
f2b-nuke is a bash script to manipulate fail2ban-client to unban IP's properly, en masse.

This script assumes the following:
You have fail2ban installed, as well as sed, wc, grep, cat and bash
It also assumes that you are running with a non-root user and require sudo to call fail2ban-client

To use:
Place f2b-nuke.sh in home directory
Make executable with: chmod +x f2b-nuke.sh
Run with: ./f2b-nuke.sh

Currently tested to work with ubuntu 14.04, 16.04 and fail2ban v0.9.3, v0.9.6

# Notes
This script will create a folder and files in your user's home directoy. Prompts ensure you are happy with this.
You do not need to run script with sudo; script will run required commands with sudo; you might be prompted for sudo password.
