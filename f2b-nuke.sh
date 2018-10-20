#!/bin/bash

#####################################################
# Script Name : f2b-nuke			    #
# Version : V0.23E (Experimental)		    #
# Date : 04/11/2017				    #
# Author : 			    #
# mail: 			    #
# Site : 			    #
# Desc. Unbans all IP's from selected fail2ban jail #
# License : MIT					    #
# Notes : Reban functionality			    #
#####################################################

##Functions##

#  line function for printing line
function line {
	echo "|-----------------------------------------------------------|"
}

#nuke function (unban)
function nuke {

	echo "| Select Jail To Nuke:                                      |"
	line #  print line

	printf "| " #tidy input
	read jail #get jail for nuke

	#  test jail before continuing...
	test=$(sudo fail2ban-client status "$jail" 2> /dev/null) #convert output into variable
	
	#  test jail variable for existance
	if [[ $test = *"Sorry"* ]]; then
		echo "| Jail '$jail' does not exist. Aborting - Goodbye!"
		line #  print line
		test= #  clear test
		exit
	
	#  test variable for banned ips
	elif [[ $test = *"Currently banned:	0"* ]]; then
		echo "| Jail '$jail' has 0 banned IP's. Aborting - Goodbye!"
		line #  print line
		test= #  clear test
		exit
	
	fi
	#end test

	line #  print line
	echo "| Jail verified as real.... moving on!                      |"

	#  test - f2b-nuke DIR does not exist - make DIR
	if [ ! -d $HOME/f2b-nuke ]; then 

		line #use print line function
		echo "| Creating folder: $HOME/f2b-nuke"
		echo "| Enter 'Y' to continue                                     |"

		printf "| " #cleanup input
		read conf
			
			#  abort DIR creation.
			if [[ $conf != "Y" ]]; then
			echo "==================== Aborting - Goodbye! ====================="
			exit
			fi

		mkdir $HOME/f2b-nuke #Create DIR - not previously created

		else #  folder already exists.. continue:
		line #  print line
		echo "| $HOME/f2b-nuke DIR already exists!"
		line #  print line
	fi

	#sleep 1 #  pause
	conf= #reset input
	sleep 3 #  pause
	echo "| Preparing $jail ban list..."
	line #  print line

	#  check for a previous jail IP list
	if [ -f $HOME/f2b-nuke/$jail-ip.lst ]; then

		#  overwrite existing .lst file prompt-----------------------------------
		echo "| $jail-ip.lst already exists. Do you want to overwrite?"
		sleep 0.2
		echo "| (file may be handy to keep)                               |"
		sleep 0.5
		echo "| Press 'Y' to overwrite and continue..                     |"
		line #  print line
	
		printf "| " #  cleanup output
		read conf
			
			#  delete older file
			if [ $conf = "Y" ]; then 
				line #  print line

				echo "| Removing $HOME/f2b-nuke/$jail-ip.lst"
				rm "$HOME"/f2b-nuke/"$jail"-ip.lst
				line #  print line
		
			#  keep older file - abort
			elif [ $conf != "Y" ]; then
				echo "=================== Aborting - Goodbye! ====================="
				exit
			fi
	
	fi

	#  start making new .lst file
	echo "| Making $jail ban list..."
	line  #  print line
	
	# query jail ban list, pipe to egrep to strip all IP's and write to file
	ADDRS=$(sudo fail2ban-client status "$jail" | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
	echo "$ADDRS" > "$HOME"/f2b-nuke/"$jail"-ip.lst

	#  Get number of IP's
	ipcount=$(wc -l < "$HOME"/f2b-nuke/"$jail"-ip.lst)
	
	#  get confirmation to unban all found IP's from jail
	echo "| Found $ipcount IP's queued for removal. Enter 'Y' to start"
	line #  print line

	conf= #  clean up conf variable

	printf "| " #cleanup output
	read conf

	if [[ $conf != "Y" ]]; then #abort banning process --------------------------
		echo "==================== Aborting - Goodbye! ===================="
		exit
	fi

	#  initiate counter
	count=0

	#  set new .lst file as source
	input="$HOME/f2b-nuke/$jail-ip.lst"

	#  initiate banloop - read .lst file line by line until EOF
	while IFS= read -r var
	do

	#  unban retrieved IP address
	ip=$(sudo fail2ban-client set "$jail" unbanip "$var" 2> /dev/null) #unban command

	count=$((count+1)) #increment counter
	
	#  test output of unbanip command for confirmation
	if [[ $ip = *"is not banned"* ]]; then
		printf "| " #  cleanup output
		echo "$var     	: No longer banned ($count/$ipcount)"
		
	#  unbanned message
	else	
		printf "| " #cleanup output
		echo "$ip      	: Unbanned ($count/$ipcount)"
	fi

	done < "$input"


	#  end message
	line #  print line
	echo "| $count/$ipcount IP's unbanned. Verify with fail2ban manually"
	echo "|================== Have a productive day! =================|"

	exit
}

# ban IPs from .lst file function
function ban {
	
	#  test for f2b-nuke dir
	if [ ! -d $HOME/f2b-nuke ]; then
		echo "======= f2b-nuke directory does not exist - Aborting ========"
		exit
	fi
	
	echo "| Please specify jail:                                      |"
	cont=0 #?

	printf '| ' #  cleanup
	read jail #  get jail
	
	# test jail before continuing
	test=$(sudo fail2ban-client status "$jail" 2> /dev/null) #convert output into variable

	if [[ $test = *"Sorry"* ]]; then #  test jail variable for existance
		echo "| Jail '$jail' does not exist. Aborting - Goodbye!"
		line # print line
		exit
	
	#  test returns null (f2b not running)
	elif [[ -z "$test" ]]; then
		echo "| Unable to test jail. Is fail2ban running? Aborting        |"
		line #  print line
		exit
	
	# test to see f2b running and jail existing
	elif [[ $test = *"Currently banned:"* ]]; then
		cont=
	fi

	echo "| Please enter the filename (located in $HOME/f2b-nuke/)"

	printf '| ' #  cleanup
	read lst
	
	#  check for .lst file input loop
	while [ ! -f $HOME/f2b-nuke/$lst ]
	do
		echo ""
		echo "| $HOME/f2b-nuke/$lst does not exist. Try again (q to quit)"
		printf '| '
		read lst
		#echo -e "\033[1K" #remove line from console
		if [[ $lst = "q" ]]; then #q actioned - quit
			echo "==================== Aborting - Goodbye! ===================="
			exit
		fi
	done
	
	echo "| $lst exists!"

	#  get number of IP's in file
	ipcount=$(wc -l < "$HOME"/f2b-nuke/"$lst")

	#  get confirmation to ban all found IPs to jail
	echo "| $ipcount IP's queued for banning to $jail. Enter 'Y' to start"
	line #  print line

	conf= #  clean up conf variable

	printf "| " #  cleanup
	read conf
	
	#  abort banning if not Y
	if [[ $conf != "Y" ]]; then 
		echo "==================== Aborting - Goodbye! ===================="
		exit
	fi

	count=0 #initiate counter

	# set .lst file as source
	input="$HOME/f2b-nuke/$lst"

	#  initiate banloop - read .lst file until EOF
	while IFS= read -r var
	do

	#  ban retreived IP address
	ip=$(sudo fail2ban-client set "$jail" banip "$var" 2> /dev/null)

	 #  test for "banned" ban message
	if [[ $ip == "$var" ]]; then
		count=$((count+1)) #  increment counter
		printf "| " #  cleanup
		echo "$var     	: banned! ($count/$ipcount)"
	
	#  unable to ban message
	else
		printf "| " #  cleanup
		echo "$ip      	: unable to ban ($count/$ipcount)"
	fi
	done < "$input"


	# end message
	line #  print line
	echo "| $count/$ipcount IP's actioned! Verify with fail2ban manually"
	echo "|================== Have a productive day! =================|"

	exit
}

function main {
	clear #  clear screen
	#  start message
	line #  print line
	/bin/echo -e "|   \e[7mf2b-nuke (V0.23E) unbans all IPs from a fail2ban jail\e[0m   |" #  script title
	line #  print line
	echo "| Please select:                                            |"
	echo "| (1) Nuke a jail (unban all IPs)                           |"
	echo "| (2) Repopulate a jail (reban from .lst)                   |"
	echo "| (any other key to quit)                                   |"
	line # print line
	
	#  get selection
	printf '| ' # cleanup
	read conf
	line # print line
	if [[ $conf == "1" ]]; then
		nuke #  run nuke function
		
	elif [[ $conf == "2" ]]; then
		ban #  run ban function
		
	elif [[ $conf != "1|2" ]]; then
		echo "===== Input does not match availabe options - Aborting! ====="
		exit
	fi
}

#  start script by calling main function
main
