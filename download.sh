#!/bin/bash

helpsection () {
echo "/----------------------------------------------------------------------------------------------------------------------------------------\ "
echo "| Script downloads recent (latest release) linux ISOs and spins a VM for a test. This is kinda distrohopper dream machine.               | "
echo "| It consist of the file with distro download functions (distrofunctions.sh) as well as this script (download.sh).                       | "
echo "| Theoretically, the script should always download recent linux ISOs without any updates. But, if the developer(s)                       | "
echo "| change the download URL or something else, it might be required to do manual changes - probably in distrofunctions.sh.                 | "
echo "| Requirements: linux, bash, curl, wget, awk, grep, xargs, pr (these tools usually are preinstalled on linux)                            | "
echo "| Some distros are shared as archive. So you'll need xz for guix, bzip2 for minix, zip for haiku & reactos, and, finally 7z for kolibri. | "
echo "| Written by SecurityXIII / Aug 2020 ~ Jan 2023 / Kopimi un-license /--------------------------------------------------------------------/ "
echo "\-------------------------------------------------------------------/"
echo "+ How to use?"
echo " If you manually pick distros (opt. one or two) you will be prompted about launching a VM for test spin for each distro."
echo " Multiple values are also supported. Please choose one out of five options:"
echo "* one distribution (e.g. type 0 for archlinux)*"
echo "* several distros - space separated (e.g. for getting both Arch and Debian, type '0 4' (without quotes))*"
echo "* 'all' option, the script will ONLY download ALL of the ISOs (warning: this can take a lot of space (100+GB) !)"
echo "* 'filesize' option will check the local (downloaded) filesizes of ISOs vs. the current/recent ISOs filesizes on the websites"
echo "* 'netbootxyz' option allows you to boot from netboot.xyz via network"
}

# NB: I wanted to add ElementaryOS but the developers made it way too hard to implement auto-downloading.
# If you can find constant mirror or place for actual release of ElementaryOS, please do a pull-request or just leave a comment.

# "WIP". Todo:	1. Multiple architecture support;
#		2. Multiple download mirror support;

ram=1024 # Amount (mb) of RAM, for VM.
cmd="qemu-system-x86_64" # The name of the qemu file to launch

# Load the functions from distrofunctions.sh:
. distrofunctions.sh

# Categories
arch=(archlinux endeavour)
deb=(debian debian_testing ubuntu kubuntu xubuntu linuxmint popos kali parrot tails)
rpm=(fedora nobara)
bsd=(freebsd netbsd openbsd)
notlinux=(freedos)

# All distributions
category_names=("Arch-based" "DEB-based" "RPM-based" "BSD" "Not linux")
distro_all=("arch" "deb" "rpm" "bsd" "notlinux")
distro_arr=("${arch[@]}" "${deb[@]}" "${rpm[@]}" "${bsd[@]}" "${notlinux[@]}")

# Legend ## Distroname ## Arch  ## Type     ## Download URL function name

# Archlinux-based distros
archlinux=("ArchLinux" "amd64" "rolling" "archurl")
endeavour=("EendeavourOS" "amd64" "latest" "endeavoururl")

# Debian/Ubuntu-based distros
debian=("Debian" "amd64" "stable" "debianurl")
debian_testing=("Debian" "amd64" "testing" "debiantestingurl")
ubuntu=("Ubuntu" "amd64" "daily-live" "ubuntuurl")
kubuntu=("Kubuntu" "amd64" "daily-live" "kubuntuurl")
xubuntu=("Xubuntu" "amd64" "daily-live" "xubuntuurl")
linuxmint=("LinuxMint" "amd64" "release" "minturl")
popos=("PopOS" "amd64" "release" "popurl")
kali=("Kali" "amd64" "kali-weekly" "kaliurl")
parrot=("Parrot" "amd64" "testing" "parroturl")
tails=("Tails" "amd64" "stable" "tailsurl")

# Fedora/RedHat-based distros
fedora=("Fedora" "amd64" "Workstation" "fedoraurl")
nobara=("Nobara" "amd64" "release" "nobaraurl")

# FreeBSD family
freebsd=("FreeBSD" "amd64" "release" "freebsdurl")
netbsd=("NetBSD" "amd64" "release" "netbsdurl")
openbsd=("OpenBSD" "amd64" "release" "openbsdurl")

# Not linux, but free
freedos=("FreeDOS" "amd64" "release" "freedosurl")

drawmenu () {

 q=0;

 for ((i=0; i<${#distro_all[@]}; i++)); do
	 col+="${category_names[$i]}: \n"
	 dist=${distro_all[$i]}
	 typeset -n arr=$dist
	 for ((d=0; d<${#arr[@]}; d++)); do
		 col+="$q = ${arr[$d]} \n"
		 (( q++ ));
	 done
 printf "$col" > col$i.tmp
 col=""
 done

 pr -m -t -w170 col*tmp && rm *tmp

}

normalmode () {
	drawmenu
	echo "Please choose distro to download (type-in number or space-separated multiple numbers):"
	read x 
			
	# Happens if the input is empty
	if [ -z "$x" ]; then echo "Empty distribution number. Please type-in number of according distro. Exiting"; exit; fi # "Empty" handling
	
	# Happens if we ask only for menu
	if [ "$x" = "menu" ]; then drawmenu; exit; fi
	
	# This questions are asked ONLY if user hadn't used the option "all".
	if [ "$x" != "all" ] && [ "$x" != "filesize" ] && [ "$x" != "netbootxyz" ] && [ "$noconfirm" != "1" ]; then
		for distr in $x; do 
		dist=${distro_arr[$distr]}
		typeset -n arr=$dist
	
		echo "You choose ${arr[0]} distro ${arr[2]}, built for ${arr[1]} arch. Do you want to download ${arr[0]} ISO? (y / n)"
		read z
		if [ $z = "y" ]; then $"${arr[3]}"; fi
		echo "${arr[0]} downloaded, do you want to spin up the QEMU? (y / n)"
		read z
	
		if [ $z = "y" ]; then
			isoname="$(echo ${arr[0]} | awk '{print tolower($0)}').iso"
			if ! type $cmd > /dev/null 2>&1; then
				echo "qemu seems not installed. Cannot run VM, skipping."
			else
			# Uncomment the following two rows (a1 & a2) and comment out others if you want to make QEMU HDD
			# qemu-img create ./${arr[0]}.img 4G                                                # a1. Creating HDD (if you want changes to be preserved)
			# qemu-system-x86_64 -hda ./${arr[0]}.img -boot d -cdrom ./${arr[0]}*.iso -m 1024   # a2. Booting from CDROM with HDD support (changes will be preserved)
				[ -f ./$isoname ] && $cmd -boot d -cdrom ./$isoname -m $ram           # b1. This is liveCD boot without HDD (all changes will be lost)
			# This is for floppy .IMG support
			# [ ! -f ./$isoname ] && imgname="$(echo ${arr[0]} | awk '{print tolower($0)}').img" && [ -f ./$imgname ] && $cmd --fda ./$imgname -m $ram
  				[ ! -f ./$isoname ] && imgname="$(echo ${arr[0]} | awk '{print tolower($0)}').img" && [ -f ./$imgname ] && $cmd -drive format=raw,file=$imgname -m $ram
			fi
		fi
	
		done
	else
	
	# All handling: automatic download will happen if user picked "all" option, no questions asked.
		if [ "$x" = "all" ]; then 
			for ((i=0; i<${#distro_arr[@]}; i++)); do xx+="$i "; done; x=$xx; 
			#for ((i=0; i<${#distro_arr[@]}; i++)); do 
			for distr in $x; do 
				dist=${distro_arr[$distr]}
				typeset -n arr=$dist
				$"${arr[3]}"
			done
		#done
		fi
		
		if [ "$noconfirm" = "1" ]; then 
			for distr in $x; do 
				dist=${distro_arr[$distr]}
				typeset -n arr=$dist
				$"${arr[3]}"
			done
		#done
		fi
		
	# Sizecheck handling: show the distribution file sizes
		if [ "$x" = "filesize" ]; then 
		for ((i=0; i<${#distro_arr[@]}; i++)); do xx+="$i "; done; x=$xx;
		#for ((i=0; i<${#distro_arr[@]}; i++)); do 
			for distr in $x; do 
				dist=${distro_arr[$distr]}
				typeset -n arr=$dist	
				$"${arr[3]}" "filesize"
			done
		#done
		fi
		
		if [ "$x" = "netbootxyz" ]; then
			echo "Downloading netboot image from netboot.xyz, please wait..." && netbootxyz
			echo "Loading netboot.xyz.iso..." && $cmd -boot d -cdrom netboot.xyz.iso -m $ram
		fi
	fi
}

quickmode () {
	IFS=,
	for distr in $distros; do
		dist=${distro_arr[$distr]}
		typeset -n arr=$dist	
		$"${arr[3]}"
	done
	exit 0;
}

VALID_ARGS=$(getopt -o hysd: --long help,noconfirm,silent,distro: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -h | --help)
        helpsection
        echo "Valid command line flags:"
		echo "-h/--help: Show this help"
        echo "-y/--noconfirm: Download specified distro without confirmation. "
        echo "-s/--silent: Don't show help or extra info."
        echo "-d/--distro: Download distributions specified in the comma-separated list. Example: 0,2,34"
        exit 0;
        ;;
    -y | --noconfirm)
        echo "-y/--noconfirm option specified. Script will download specified distro without confirmation."
        noconfirm=1
        shift
        ;;
    -s | --silent)
        echo "-s/--silent option specified. Script will not show help or extra info."
        silent=1
        shift
        ;;
    -d | --distro)
        echo "-d/--distro option specified. Script will download distributions with the following numbers: '$2'"
        distros="$2"
        quickmode
        ;;
    --) shift; 
        break 
        ;;
  esac
done

if [ "$silent" != "1" ]; then helpsection; fi

normalmode
