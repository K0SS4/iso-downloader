#!/bin/bash

helpsection ()
{
    echo "+ How to use?"
    echo " You have a couple of options:"
    echo "* download one ISO (e.g. type 0 for archlinux)*"
    echo "* download several ISOs - space separated (e.g. for getting both Arch and Endeavour, type '0 1' (without quotes))*"
    echo "* 'all' option, the script will download ALL of the ISOs (warning: this can take a lot of space!)"
    echo "* 'filesize' option will check the local (downloaded) filesizes of ISOs vs. the current/recent ISOs filesizes on the websites"
    echo "* 'netbootxyz' option allows you to boot from netboot.xyz via network"
}

# Load the functions from systemfunctions.sh:
. systemfunctions.sh

# Categories
arch=(archlinux endeavour)
deb=(debian debian_testing ubuntu kubuntu xubuntu linuxmint popos kali parrot tails)
rpm=(fedora nobara)
bsd=(freebsd netbsd openbsd)
other=(memtest64bit memtest32bit antiviruslive)
notlinux=(freedos netbootxyz)

# All distributions
category_names=("Arch-based" "DEB-based" "RPM-based" "BSD" "Other" "Not linux")
types=("arch" "deb" "rpm" "bsd" "other" "notlinux")
system_arr=("${arch[@]}" "${deb[@]}" "${rpm[@]}" "${bsd[@]}" "${other[@]}" "${notlinux[@]}")

# Legend ## Systemname ## Arch ## Type ## Download URL function name

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
fedora=("Fedora" "amd64" "Xfce" "fedoraurl")
nobara=("Nobara" "amd64" "release" "nobaraurl")

# FreeBSD family
freebsd=("FreeBSD" "amd64" "release" "freebsdurl")
netbsd=("NetBSD" "amd64" "release" "netbsdurl")
openbsd=("OpenBSD" "amd64" "release" "openbsdurl")

# Other
memtest64bit=("Memtest86+" "amd64" "release" "memtest64url")
memtest32bit=("Memtest86+" "i386" "release" "memtest32url")
antiviruslive=("Antivirus Live CD" "amd64" "release" "antivirusliveurl")

# Not linux, but free
freedos=("FreeDOS" "amd64" "release" "freedosurl")
netbootxyz=("netboot.xyz" "amd64" "release" "netbootxyz")

drawmenu ()
{
    q=0;

    for ((i=0; i<${#types[@]}; i++)); do
        col+="${category_names[$i]}: \n"
        dist=${types[$i]}
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

normalmode ()
{
    drawmenu
    echo "Please choose ISO to download (type-in number or space-separated multiple numbers):"
    read x 

    # Happens if the input is empty
    if [ -z "$x" ]; then echo "Empty system number. Please type-in number of according system. Exiting"; exit; fi

    # This questions are asked ONLY if user hadn't used the option "all".
    if [ "$x" != "all" ] && [ "$x" != "filesize" ] && [ "$x" != "netbootxyz" ] && [ "$noconfirm" != "1" ]; then
        for sys in $x; do 
            s=${system_arr[$sys]}
            typeset -n arr=$s

            echo "You chose ${arr[0]} system ${arr[2]}, built for ${arr[1]} arch. Do you want to download ${arr[0]} ISO? (y / n)"
            read z
            if [ $z = "y" ]; then $"${arr[3]}"; fi
        done
    else
        # All handling: automatic download will happen if user picked "all" option, no questions asked.
        if [ "$x" = "all" ]; then 
            for ((i=0; i<${#system_arr[@]}; i++)); do xx+="$i "; done; x=$xx; 

            for sys in $x; do 
                s=${system_arr[$sys]}
                typeset -n arr=$s
                $"${arr[3]}"
            done
        fi

        if [ "$noconfirm" = "1" ]; then 
            for sys in $x; do 
                s=${system_arr[$sys]}
                typeset -n arr=$s
                $"${arr[3]}"
            done
        fi

        # Sizecheck handling: show the distribution file sizes
        if [ "$x" = "filesize" ]; then 
            for ((i=0; i<${#system_arr[@]}; i++)); do xx+="$i "; done;
            x=$xx;

            for sys in $x; do 
                s=${system_arr[$sys]}
                typeset -n arr=$s
                $"${arr[3]}" "filesize"
            done
        fi

        if [ "$x" = "netbootxyz" ]; then
            echo "Downloading netboot image from netboot.xyz, please wait..." && netbootxyz
            echo "Loading netboot.xyz.iso..." && $cmd -boot d -cdrom netboot.xyz.iso -m $ram
        fi
    fi
}

quickmode ()
{
    IFS=,
    for sys in $picked; do
        s=${system_arr[$sys]}
        typeset -n arr=$s
        $"${arr[3]}"
    done
    exit 0;
}

VALID_ARGS=$(getopt -o hyls: --long help,noconfirm,list,system: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while true
do
    case "$1" in
        -h | --help)
            helpsection
            echo "Valid command line flags:"
            echo "-h/--help: Show this help"
            echo "-y/--noconfirm: Download specified system without confirmation. "
            echo "-l/--list: List all of the available systems with it's corresponding number."
            echo "-s/--system: Download systems specified in the comma-separated list. Example: 0,2,34"
            exit 0;
            ;;
        -y | --noconfirm)
            echo "-y/--noconfirm option specified. Script will download specified system without confirmation."
            noconfirm=1
            shift
            ;;
        -l | --list)
            echo "List of supported systems:"
            drawmenu
            exit 0;
            ;;
        -s | --system)
            echo "-s/--system option specified. Script will download systems with the following numbers: '$2'"
            picked="$2"
            quickmode
            ;;
        --) shift; 
            break 
            ;;
    esac
done

normalmode
