#!/bin/bash

source $(dirname "$0")/../common.sh "$@"

function show_warning()
{

# Usage: show_warning <UNINSTALL_ITEM> <UNINSTALL_DIRS> <PREVIOUS_ARGS>
local uninstall_item="$1"
local uninstall_dir="$2"
shift 2

if whiptail --title "!! $uninstall_item !!" --yesno "Are you sure you would like to uninstall $uninstall_item?\n\nWhile you can reinstall $uninstall_item again from pengwin-setup, any of your own files in the $uninstall_dir install directory(s) WILL BE PERMANENTLY DELETED.\n\nSelect 'yes' if you would like to proceed" 14 85 ; then
	if whiptail --title "!! $uninstall_item !!" --yesno "Are you absolutely sure you'd like to proceed in uninstalling $uninstall_item?" 7 85 ; then
		echo "User confirmed $uninstall_item uninstall"
		return
	fi
fi

echo "User cancelled $uninstall_item uninstall"
bash ${SetupDir}/uninstall.sh "$@"

}

function rem_file()
{

# Usage: remove_file <FILE>
echo "Removing file: '$1'"
if [[ -f "$1" ]] ; then
	rm -f "$1"
else
	echo "... not found!"
fi

}


function rem_dir()
{

# Usage: remove_dir <DIR>
echo "Removing directory: '$1'"
if [[ -d "$1" ]] ; then
	rm -rf "$1"
else
	echo "... not found!"
fi

}

function sudo_rem_file()
{

# Same as above, just with administrative privileges
echo "Removing file: '$1'"
if [[ -f "$1" ]] ; then
	sudo rm -f "$1"
else
	echo "... not found!"
fi

}

function sudo_rem_dir()
{

# Same as above, just with administrative privileges
echo "Removing directory: '$1'"
if [[ -d "$1" ]] ; then
	sudo rm -rf "$1"
else
	echo "... not found!"
fi

}

function clean_file()
{

# Usage: clean_file <FILE> <REGEX>

# Following n (node version manager) install script,
# best to clean file by writing to memory then
# writing back to file
local fileContents
fileContents=$(grep -Ev "$2" "$1")
printf '%s\n' "$fileContents" > "$1"

}

function sudo_clean_file()
{

# Same as above, just with administrative privileges
local fileContents
fileContents=$(sudo grep -Ev "$2" "$1")
sudo bash -c "printf '%s\\n' '$fileContents' > '$1'"

}

function inclusive_file_clean()
{

# Usage: inclusive_file_clean <FILE> <SEARCHSTRING>
# meow
local fileContents
fileContents=$(sed -e ':a' -e 'N' -e '$!ba' -e "s|$2\\n.*\\n$2||g" "$1")
printf '%s\n' "$fileContents" > "$1"

}

function sudo_inclusive_file_clean()
{

# Same as above
local fileContents
fileContents=$(sudo sed -e ':a' -e 'N' -e '$!ba' -e "s|$PENGWIN_STRING\\n.*\\n$PENGWIN_STRING||g" "$1")
sudo bash -c "printf '%s\\n' '$fileContents' > '$1'"

}

function remove_package()
{

# Usage: remove_package <PACKAGES...>
echo "Removing APT packages: $@"
local installed

installed=""
for i in "$@" ; do
	if (dpkg-query -s "$i" | grep 'installed') > /dev/null 2>&1 ; then
		installed="$i $installed"
	else
		echo "... $i not installed!"
	fi
done

if [[ $installed != "" ]] ; then
	echo "Uninstalling: $installed"
	sudo apt-get remove -y -q $installed --autoremove
fi

}

function pip_uninstall()
{

# Usage: pip_uninstall <2/3> <PACKAGE>
local pip

case "$1" in
	"")
	pip='pip'
	;;
	2)
	pip='pip'
	;;
	3)
	pip='pip3'
	;;
esac

echo "Removing $2"
if $pip --version > /dev/null 2>&1 ; then
	if $pip list | grep "$2" > /dev/null 2>&1 ; then
		$pip uninstall "$2"
		return
	fi
fi

echo "... not installed!"

}

function sudo_pip_uninstall()
{

# Same as above, but with administrator privileges
local pip

case "$1" in
	"")
	pip='pip'
	;;
	2)
	pip='pip'
	;;
	3)
	pip='pip3'
	;;
esac

echo "Removing $2"
if $pip --version > /dev/null 2>&1 ; then
        if $pip list | grep "$2" > /dev/null 2>&1 ; then
                sudo $pip uninstall "$2"
                return
	fi
fi

echo "... not installed!"

}
