#!/bin/bash

#####################################################
# Script Name : f2b-nuke			    #
# Version : V0.21F (Final)			    #
# Date : 19/2/2017				    #
# Author : necpock / Joe			    #
# mail: necpock@gmail.com			    #
# Site : jsephler.co.uk				    #
# Desc. Unbans all IP's from selected fail2ban jail #
# License : MIT					    #
#####################################################

function line { #line function for printing line
echo "|-----------------------------------------------------------|"
}


line #use print line function
/bin/echo -e "| \e[7mf2b-nukebans V0.21E unbans all ip's from a specified jail\e[0m |" #Title
echo "| Select Jail To Nuke:                                      |"
line #use print line function

printf "| " #tidy up input

read jail #Get jail name for nuke

if [ ! -d $HOME/f2b-nukebans ]; then #No f2b-nukebans folder in home DIR - make DIR

line #use print line function
echo "| Creating folder: $HOME/f2b-nukebans"
echo "| Enter 'Y' to continue                                     |"

printf "| " #cleanup input
read conf
	
	if [ $conf != "Y" ]; then #Abort DIR creation.
	echo "==================== Aborting - Goodbye! ====================="
	exit
	fi

mkdir $HOME/f2b-nukebans #Create DIR - not previously created

else #folder already exists.. continue:
line #use print line function
echo "| $HOME/f2b-nukebans/ DIR already exists!"
line #use print line function
fi

sleep 1 #pause

conf= #reset input

echo "| Getting IP list from fail2ban...                          |"
line #use print line function

#Get Jail status output... [ Modify fail2ban command below if your command is different [1/3] ]
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

sudo fail2ban-client status "$jail" | cat > "$HOME"/f2b-nukebans/"$jail"-ip.tmp

sleep 2
#sort raw file --------------------------------

echo "| Preparing $jail ban list..."
line #use print line function


if [ -f $HOME/f2b-nukebans/$jail-ip.lst ]; then #Check for a previous jail IP list

#Overwrite existing .lst file prompt-----------------------------------
echo "| $jail-ip.lst already exists. Do you want to overwrite?"
sleep 0.2
echo "| (file may be handy to keep)                               |"
sleep 0.5
echo "| Press 'Y' to overwrite and continue..                     |"
line #use print line function
printf "| " #cleanup output
read conf
	
	if [ $conf = "Y" ]; then #Delete older file - not needed ------------
	line #use print line function

	echo "| Removing $HOME/f2b-nukebans/$jail-ip.lst"
	rm "$HOME"/f2b-nukebans/"$jail"-ip.lst
	line #use print line function

	elif [ $conf != "Y" ]; then #Keep older file - ABORT --------------
	echo "=================== Aborting - Goodbye! ====================="
	exit
	fi
	
fi

#Start making new .lst files --------------------

echo "| Making new $jail ban list..."
line #use print line function

#Below : Sort contents of RAW tmp file into seperate lines
sed 's/\s/\n/g' "$HOME"/f2b-nukebans/"$jail"-ip.tmp | cat > "$HOME"/f2b-nukebans/"$jail"-ip.tmp1

rm "$HOME"/f2b-nukebans/"$jail"-ip.tmp #Remove redundant tmp file

#Below : Extract IP's Per line and pass to final file .lst
sed -rn '/((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])/p' "$HOME"/f2b-nukebans/"$jail"-ip.tmp1 | cat > "$HOME"/f2b-nukebans/"$jail"-ip.lst

rm "$HOME"/f2b-nukebans/"$jail"-ip.tmp1  #Remove redundant tmp1 file

#Get Confirmation to unban all found IP's from jail -------------------------------

ipcount=$(wc -l < "$HOME"/f2b-nukebans/"$jail"-ip.lst) #Get number of IP's

echo "| Found $ipcount IP's queued for removal. Enter 'Y' to start"
line #use print line function
conf= #clean up conf variable
printf "| " #cleanup output
read conf
	if [ $conf != "Y" ]; then #abort banning process --------------------------
	echo "==================== Aborting - Goodbye! ===================="
	exit
	fi

count=0 #initiate counter

input="$HOME/f2b-nukebans/$jail-ip.lst" #Set lst file as source

while IFS= read -r var #initiate banloop - read .lst file line by line until the end
do

#Unban retreived IP addresses (Loop till end). [ Modify fail2ban command below if if your command is different [3/3] ]

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

line #use print line function
echo "| $count/$ipcount IP's unbanned. Verify with fail2ban manually"
echo "|================== Have a productive day! =================|"

#cleanup variables-----------------------------
count=
ip=
ipcount=
input=

exit
