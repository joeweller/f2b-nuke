#!/bin/bash

#####################################################
# Script Name : f2b-nuke			    #
# Version : V0.22E (Experimental)		    #
# Date : 11/3/2017				    #
# Author : necpock / Joe			    #
# twitter: @WJ0S3PH				    #
# Site : jsephler.co.uk				    #
# Desc. Unbans all IP's from selected fail2ban jail #
# License : MIT					    #
#####################################################

##Functions
function line { #line function for printing line
echo "|-----------------------------------------------------------|"
}

#start message --------------------------
line #print line
/bin/echo -e "| \e[7mf2b-nukebans V0.22E unbans all ip's from a specified jail\e[0m |" #Title
echo "| Select Jail To Nuke:                                      |"
line #print line

printf "| " #tidy input
read jail #get jail for nuke

#test jail before continuing...
test=$(sudo fail2ban-client status "$jail" 2> /dev/null) #convert output into variable

if [[ $test = *"Sorry"* ]]; then #test jail variable for existance
	echo "| Jail '$jail' does not exist. Aborting - Goodbye!"
	line #use print line function
	test= #clear test
	exit
	
elif [[ $test = *"Currently banned:	0"* ]]; then #test variable for banned ips
	echo "| Jail '$jail' has 0 banned IP's. Aborting - Goodbye!"
	line #use print line function
	test= #clear test
	exit
	
fi
#end test

line #print line
echo "| Jail verified as real.... moving on!                      |"

if [ ! -d $HOME/f2b-nuke ]; then #f2b-nuke DIR does not exist - make DIR

	line #use print line function
	echo "| Creating folder: $HOME/f2b-nuke"
	echo "| Enter 'Y' to continue                                     |"

	printf "| " #cleanup input
	read conf
	
		if [ $conf != "Y" ]; then #Abort DIR creation.
		echo "==================== Aborting - Goodbye! ====================="
		exit
		fi

	mkdir $HOME/f2b-nuke #Create DIR - not previously created

	else #folder already exists.. continue:
	line #print line
	echo "| $HOME/f2b-nuke DIR already exists!"
	line #print line
fi

sleep 1 #pause
conf= #reset input
sleep 2 #pause
echo "| Preparing $jail ban list..."
line #print line


if [ -f $HOME/f2b-nuke/$jail-ip.lst ]; then #Check for a previous jail IP list

	#Overwrite existing .lst file prompt-----------------------------------
	echo "| $jail-ip.lst already exists. Do you want to overwrite?"
	sleep 0.2
	echo "| (file may be handy to keep)                               |"
	sleep 0.5
	echo "| Press 'Y' to overwrite and continue..                     |"
	line #use print line function
	
	printf "| " #cleanup output
	read conf
	
		if [ $conf = "Y" ]; then #Delete older file ------------
			line #print line

			echo "| Removing $HOME/f2b-nuke/$jail-ip.lst"
			rm "$HOME"/f2b-nuke/"$jail"-ip.lst
			line #print line

			elif [ $conf != "Y" ]; then #Keep older file - ABORT --------------
			echo "=================== Aborting - Goodbye! ====================="
			exit
		fi
	
fi

#Start making new .lst file --------------------

echo "| Making $jail ban list..."
line #use print line function

ADDRS=$(sudo fail2ban-client status "$jail" | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
echo "$ADDRS" > "$HOME"/f2b-nuke/"$jail"-ip.lst

#Get Confirmation to unban all found IP's from jail -------------------------------
ipcount=$(wc -l < "$HOME"/f2b-nuke/"$jail"-ip.lst) #Get number of IP's

echo "| Found $ipcount IP's queued for removal. Enter 'Y' to start"
line #print line

conf= #clean up conf variable

printf "| " #cleanup output
read conf

if [ $conf != "Y" ]; then #abort banning process --------------------------
	echo "==================== Aborting - Goodbye! ===================="
	exit
fi

count=0 #initiate counter


input="$HOME/f2b-nuke/$jail-ip.lst" #Set lst file as source

while IFS= read -r var #initiate banloop - read .lst file line by line until the end
do

#Unban retreived IP addresses (Loop till end)
ip=$(sudo fail2ban-client set "$jail" unbanip "$var" 2> /dev/null) #unban command

count=$((count+1)) #increment counter

if [[ $ip = *"is not banned"* ]]; then
	printf "| " #cleanup output
	echo "$var     	: No longer banned ($count/$ipcount)"
else	
	printf "| " #cleanup output
	echo "$ip      	: Unbanned ($count/$ipcount)" #unbanned message
fi

done < "$input"


#End Message-----------------------------------
line #print line
echo "| $count/$ipcount IP's unbanned. Verify with fail2ban manually"
echo "|================== Have a productive day! =================|"

#cleanup variables-----------------------------
count=
ip=
ipcount=
input=

exit
