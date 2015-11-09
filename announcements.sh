#!/bin/bash

##############################################################
#
# Vanilla Minecraft Announcements Script
# 2015-11-08
#
# https://github.com/seifer44/minecraft-announcements
# Version 1.0.0
#
##############################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################

######################
#     VARIABLES      #
######################

# Log file location of the Minecraft service logs. Generally, this lives under
# $MINECRAFT/logs/latest.log
loglocation=/opt/minecraft/service/logs/latest.log



######################
#     FUNCTIONS      #
######################
as_user() {
	if [ $user == $serverusername ] ; then
		bash -c "$1"
	else
		su - $serverusername -c "$1"
	fi
}


######################
# CORE FUNCTIONALITY #
#      STARTUP       #
######################

if [ ! -d announcements.d ]
then
	mkdir announcements.d
	echo "Directory announcements.d was missing! Created it."
fi

if [ $(ls announcements.d | wc -l) -eq 0 ]
then
	echo -e "Directory announcements.d has nothing in it! This script won't work unless you define some announcements!\nRead the README for more info. Exiting error code 1."
	exit 1
fi

cd announcements.d



IFSorig=$IFS
IFS="
"
### We analyze all of the files with arguments here.
# If the file only has 2 lines, then just dump line 1 into the announcechecks array
# and line 2 as announcemsgs.
# If lines are greater than 2, then make the announcemsgs line the last line each time.
for i in $(ls)
do
	echo "Analyzing file $i"	# Debug
	
	linenum=$(wc -l $i | cut -f1 -d " ")
	if [ $linenum -gt 2 ]
	then
		echo "   File $i has multiple arguments in it!"		# Debug
		echo "   Number of lines: $linenum"						# Debug
		echo "   Expressions: $(expr $linenum - 1)"			# Debug
		
		count=1
		while [[ $count -lt $linenum ]]
		do
			announcechecks+=( "$(sed -n $count\p $i)" )
			announcemsgs+=( "$(sed -n $linenum\p $i)" )
			
			count=$(( $count + 1))
		done
	else
		echo "   File $i has a single argument!"			# Debug
		announcechecks+=( $(sed -n '1p' $i) )
		announcemsgs+=( $(sed -n '2p' $i) )
	fi
done



echo -e "\n#################\n"
count=0										# Debug
while [ $count -lt ${#announcechecks[*]} ]	# Debug
do 											# Debug
		echo "Argument & msg:"				# Debug
		echo "   ${announcechecks[$count]}"		# Debug
		echo -e "   ${announcemsgs[$count]}\n"		# Debug
		count=$(( $count + 1 ))
done										# Debug



# Create a tmp file that gets emptied at startup and
# lists the maximum number of arguments for each bang arg
cat /dev/null > .announcements.sh.tmp
echo "Cleared .announcements.sh.tmp"
for i in ${announcechecks[*]}
do
	if [[ $i == "!"* ]]
	then
		echo "Populating .announcements.sh.tmp with $i"		# Debug
		
		# Since ls always goes in alphabetical order, the higher numbers will come later.
		# If we get a higher number, then simply trash the old entry.
		# If the argument hasn't been entered in yet, then throw it in.
		grep -q $(echo $i | cut -f1 -d " ") .announcements.sh.tmp
		if [ $? -eq 0 ]
		then
			echo "Found a duplicate! Removed the lesser arg."		# Debug
			sed -i "/$(echo $i | cut -f1 -d ' ')/d" .announcements.sh.tmp
		fi
		
		echo $i >> .announcements.sh.tmp
	fi
done
IFS=$IFSorig



echo -e "\n#################\n\nScript is now running. To apply any changes, restart the script.\nPress Control + C to exit the script."				# Debug



######################
#   LOOP FUNCTION    #
######################

while read line
do
	useronline=$(echo $line | cut -d " " -f4 | sed 's/\[.*//g' | sed 's/<//g' | sed 's/>//g')
	firstarg=$(echo $line | cut -d " " -f5)
	# Set second incoming line argument only if it starts with a bang
	if [[ $(echo $line | cut -d " " -f5 ) == "!"* ]]
	then
		secondbangarg=$(echo $line | cut -d " " -f6)
		
		if [ -z $secondbangarg ]
		then
			secondbangarg=1
		fi
	fi
	
	
	
	# Run the incoming line against all of the checks we found above.
	argnum=${#announcechecks[@]}
	count=0
	while [ $count -lt $argnum ]
	do
#		echo "Incoming line. Testing against \"${announcechecks[$count]}\"" # Debug

		# Test if the pattern in each file matches the line that just came in.
		if [[ "$line" == *${announcechecks[$count]} ]]
		then
#			echo "   Found match!" # Debug
			as_user "screen -p 0 -S minecraft -X stuff \"tellraw $useronline $(echo ${announcemsgs[$count]} | sed 's/"/\\"/g') $(printf \\r)\""
			
			
			
#			echo "   Max args for $firstarg: $(grep $firstarg .announcements.sh.tmp | cut -f2 -d " ")"		# Debug
			# If there is more than just 1 file for that ! argument, mention that!
			if [ $(grep $firstarg .announcements.sh.tmp | wc -w) -eq 2 ]
			then
				if [ $secondbangarg -lt $(grep $firstarg .announcements.sh.tmp | cut -f2 -d " ") ]
				then
#					echo "   Higher number of arguments found. Announcing." # Debug
					# If you want to use a different message, make sure you escape EVERY " and ' except for the very first and last ".
					as_user "screen -p 0 -S minecraft -X stuff \"tellraw $useronline $( echo "[\"\",{\"text\":\"There are more arguments for $firstarg\",\"color\":\"dark_green\"},{\"text\":\". Try $firstarg $((secondbangarg + 1)) for more info.\"}]"| sed 's/"/\\"/g')$(printf \\r)\""
				fi
			fi
		fi
		count=$(( $count + 1 ))
#		echo "   Line test $count" 		# Debug
	done
done < <(tail -f -n 0 $loglocation)
