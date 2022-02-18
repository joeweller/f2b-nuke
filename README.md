# Archival Notice
This repository has now been archived; although in some edge-cases it may still be useful, it will no longer be maintained and should be considered unmaintainable.
Thanks!

# f2b-nuke
f2b-nuke is a bash script to manipulate fail2ban-client to unban IP's properly, en masse.
Interactive script.. no args

This script assumes the following:<br>
You have fail2ban, wc, grep, cat and bash installed.<br>
It also assumes that you are running with a non-root user with sudo privileges.

# Usage
Place f2b-nuke.sh in your home directory<br>
Make executable with: chmod +x f2b-nuke.sh<br>
Run with: ./f2b-nuke.sh<br>

# Tested
Currently tested to work with ubuntu 14.04, 16.04 and fail2ban v0.9.3, v0.9.6

# Notes
This script will create a folder (and ip list files within), in your user's home directory. Prompts ensure you are happy with this.
You do not need to run script with sudo; script will run required commands with sudo; you might be prompted for sudo password.
