#!/bin/bash

# Version: 20140506

# Copyright (C) 2014  VulpiArgenti
# Installer.sh tweaked by @johntroony << Twitter

warn="\e[1;31m"      # warning           red
info="\e[1;34m"      # info              blue
q="\e[1;32m"         # questions         green

clear

echo -e "$info\n      PwnSTAR INSTALLER"
echo -e "$info      =================\n"

# Checking if User is root
if [[ "$(id -u)" != "0" ]]; then
    echo -e "$warn\nThis script must be run as root" 1>&2
exit 0
fi

# Print current working Dir and get Dir to install PwnSTAR 
echo -e "$warn\nImportant: run this installer from the same directory as the git clone eg /git/PwnSTAR\n"
pdir=$(pwd)
echo -e "$info\nYou Current Working Dir is: $pdir"
sleep 1
echo -e "$q\nPlease set where to install PwnSTAR? e.g. /usr/bin"
read var


# Check if PwnSTAR exists in the dir to install
if [ -e $varx/PwnSTAR/ ]; then
	echo -e "$warn\nSeems like PwnSTAR already exist in $var"
	echo -e "$q\nContinue with Installation?"
	read -p "Enter: yes or no " ncontinue;

	while [[ -z "$ncontinue" ]]; do
		echo -e "$info\n"
		read -p "Please enter yes or no " ncontinue
	done

	echo -e "$q\n $ncontinue was selected."
	anzwer=${ncontinue,,}

	# Setting /opt/ as default installation dir
	if [[ $anzwer == "no" || $anzwer == "n" ]]; then
		read -p "Enter another directory to use?  [/opt/]  " var
		while [[ -z "$var" ]]; do
			var="/opt"
		done
		echo "$var is set as your default installation dir."

		# Prepare Dir to install PwnSTAR
		if [[ ! $var =~ ^/ ]];then  # if "/" is omitted eg "opt"
		    var="/""$var"           # then add it
		fi

		if [[ ! -d $var/PwnSTAR/ ]];then
		    mkdir $var/PwnSTAR/
		fi

	fi
	
fi

# Set Permission for pwnstar 
chmod 744 pwnstar && cp -bi --preserve pwnstar $var/
cp How_to_use.txt $var/PwnSTAR/

# copy/install pwnstar to the Dir
if [[ -x $var/pwnstar ]];then
    echo -e "$info\nPwnSTAR installed to $var\n"
else
    echo -e "$warn\nFailed to install PwnSTAR!\n"
fi

# Set web page permissions
echo -e "$info\nSetting web page permissions"
cd html/

for folder in $(find $PWD -maxdepth 1 -mindepth 1 -type d); do
    chgrp -R www-data $folder
    chmod -f 774 $folder/*.php
    chmod -f 664 $folder/formdata.txt
    cp -Rb --preserve $folder /var/www/
    if [[ $? == 0 ]];then
        echo -e "$info\n$folder moved successfully..."
    else
        echo -e "$warn\nError moving $folder!\nPlease check manually"
    fi
done

# Check if some of the required programs are installed
declare -a progs=(Eterm macchanger aircrack-ng ferret sslstrip apache2 dsniff)

for i in ${progs[@]}; do
    echo -e "$info"
    if [[ ! -x /usr/bin/"$i" ]] && [[ ! -x /usr/sbin/"$i" ]] && [[ ! -x /usr/share/"$i" ]];then
	i="$(tr [A-Z] [a-z] <<< "$i")" 	# to deal with Eterm/eterm
	apt-get install "$i"
    else
	echo -e "$info\n$i already present"
    fi
done

# Check if dhcpd is installed, install if not
if [[ ! -x /usr/sbin/dhcpd ]];then
    echo -e "$q\nInstall isc-dhcp-server? (y/n)"
    read var
    if [[ $var == y ]];then
        apt-get install isc-dhcp-server
    fi
else
    echo -e "$info\nIsc-dhcp-server already present"
fi

# Check if incrond is installed if not, install it.
if [[ ! -e /usr/sbin/incrond ]];then 
    echo -e "$q\nInstall incron? (y/n)"
    read var
    if [[ $var == y ]];then
        apt-get install incron
    fi
else
    echo -e "$info\nIncron already present\n"
fi

# Check if mdk3 is installed if not, install it.
if [[ ! -x  /usr/bin/mdk3 ]] && [[ ! -x /usr/sbin/mdk3 ]] && [[ ! -x  /usr/share/mdk3 ]];then
    if [[ $(cat /etc/issue) =~ Kali ]];then
	apt-get install mdk3
    else
	echo -e "$info\nInstalling MDK3 to usr/bin"
	wget http://homepages.tu-darmstadt.de/~p_larbig/wlan/mdk3-v6.tar.bz2
	tar -xvjf mdk3-v6.tar.bz2
	cd mdk3-v6
	sed -i 's|-Wall|-w|g' ./Makefile
	sed -i 's|-Wextra||g' ./Makefile
	sed -i 's|-Wall||g' ./osdep/common.mak
	sed -i 's|-Wextra||g' ./osdep/common.mak
	sed -i 's|-Werror|-w|g' ./osdep/common.mak
	sed -i 's|-W||g' ./osdep/common.mak
	make
	chmod +x mdk3
	cp -Rb --preserve mdk3 /usr/bin
	cd ..
    fi
else
    echo -e "$info\nMDK3 already present\n"
fi

# Print Exit message(s) to the user
echo -e "$info\nFinished. \n\tIf there were no error messages, you can safely delete the git clone.
	Run by typing \"pwnstar\" (presuming your installation directory is on the path).
	The README is in $var/PwnSTAR/"
echo -e "$warn\nNote: this script does not install metasploit\n"

sleep 2
exit 0