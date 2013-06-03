#!/bin/bash  							

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# update-hosts.sh							#
# Written by Lawrence Hoffman 						#
# Mon Dec 27 12:07 AKST 2010						#
# This is a very rudimentary bash script for updating a linux hosts	#
# file. For questions or comments contact the author at 		#
# lawrence@lawrencehoffman.net						#
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

echo # Drop down a line before we start for readability
echo "update-hosts.sh By Lawrence Hoffman (lawrence@lawrencehoffman.net)"
echo "ENJOY!"; echo;

# Check that we're in a BASH shell
if test -z "$BASH" ; then
  echo "update-hosts.sh must be run in the BASH shell... Aborting."; echo;
  exit 192
fi

# Check for root user
if [ $(whoami) != "root" ]; then
  echo "update-hosts.sh must be run as root... Aborting."; echo;
  exit 192
fi

# Sanity checks:
echo "Checking that all required software is installed."; echo;
type -P wget &>/dev/null || { echo "Error: update-hosts.sh requires the program wget... Aborting."; echo; exit 192; }
type -P sed &>/dev/null  || { echo "Error: update-hosts.sh requires the program sed... Aborting."; echo;exit 192; }
type -P date &>/dev/null || { echo "Error: update-hosts.sh requires the program date... Aborting."; echo; exit 192; }

# Back up host file:
echo "Creating a backup of /etc/hosts in the file /etc/ORIGHOSTS"; echo;
cat /etc/hosts > /etc/ORIGHOSTS

# Download updated hosts file
echo "Downloding file at http://www.mvps.org/winhelp2002/hosts.txt";
wget --quiet http://www.mvps.org/winhelp2002/hosts.txt --directory-prefix=/etc/; echo;

# Format new hosts file
echo "Formatting... "; echo;
sed -i -n -e 's/127.0.0.1/0.0.0.0/p' /etc/hosts.txt 
sed -i -e '/localhost/d' /etc/hosts.txt

# Delete old Addblock
echo "Updating... "; echo;
sed -i -e '/update-hosts.sh/d' /etc/hosts
sed -i -e '/0.0.0.0/d' /etc/hosts

# Install new Addblock
UPDATESTR="# update-hosts.sh last update $(date) #"
echo $UPDATESTR >> /etc/hosts
cat /etc/hosts.txt >> /etc/hosts

# Clean up
echo "Cleaning up..."; echo;
rm /etc/hosts.txt

# Exit clean
echo "update-hosts.sh update complete."; echo;
exit 0
