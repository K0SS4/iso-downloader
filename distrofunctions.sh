#!/bin/bash

# Download functions and commands

wgetcmd () { 
echo "Downloading $new to $output"
wget -q --show-progress -c "$new" -O "$output" -o /dev/null
}

# Function to only get filesize
getsize () { 
abc=$(wget --spider $new 2>&1)
y=$(echo $abc | awk -F"Length:" '{ print $2 }' | awk -F"[" '{ print $1 }')
ss=$(ls -l -B $output | awk -F" " '{ print $5 }')
sh=$(ls -lh $output | awk -F" " '{ print $5 }')
printf "File: $new has size: $y while on disk it is $output - $ss ($sh) \n"
}

# This can be adopted for using torrents instead of direct HTTP/FTP files
ariacmd () { aria2c --seed-time=0 -c $new; } 
# Set seeding time after downloading to zero ( this is sad :-( remove --seed-time=0 if you like to seed :-) )

# Other functions

notlive () {
echo " / / ---------------------------------------------------------------------- \ \ "
echo " | | Note: this is not a live disk (it'll require further installation).    | | "
echo " \ \ -----------------------------------------------------------------------/ / "
}

notlinux () {
echo " / / ------------------------------------------------------------------------------------- \ \ "
echo " | | Note: this isn't actually linux. It was included as it's important opensource project | | "
echo " \ \ --------------------------------------------------------------------------------------/ / "
}

empty () {
echo "The file $output is empty. Please download it first." # This function does nothing
}

checkfile () {
if [ "$1" == "filesize" ]; then 
	[ -s $output ] && getsize || empty 
else
	wgetcmd
fi
}

# Update latest distro URL functions

archurl () {
mirror="https://archlinux.org/download/"
x=$(curl -s $mirror | grep -m1 geo | awk -F"\"" '{ print $2 }')
y=$(curl -s $x | grep -m1 archlinux | awk -F".iso" '{ print $1 }' | awk -F"\"" '{ print $2 }' );
new="$x/$y.iso"
output="archlinux.iso"
checkfile $1
}

endeavoururl () {
mirror="https://sourceforge.net/projects/endeavouros-repository/files/latest/download"
new="$mirror"
output="endeavour.iso"
checkfile $1
}

debianurl () {
mirror="https://cdimage.debian.org/cdimage/release/"
version=$(curl -s $mirror | grep "<a href" -m4 | tail -n1 | awk -F "\"" '{print $6}')
new="$mirror${version}amd64/iso-dvd/debian-${version:0:-1}-amd64-DVD-1.iso"
output="debian.iso"
notlive
checkfile $1
}

debiantestingurl () {
x="https://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-dvd/debian-testing-amd64-DVD-1.iso"
new="$x"
output="debian_testing.iso"
notlive
checkfile $1
}

ubuntuurl () {
mirror="http://cdimage.ubuntu.com/daily-live/current/"
x=$(curl -s $mirror | grep -m1 desktop-amd64.iso | awk -F\" '{ print $2 }' | awk -F\" '{ print $1 }')
new="$mirror/$x"
output="ubuntu.iso"
checkfile $1
}

kubuntuurl () {
mirror="http://cdimage.ubuntu.com/kubuntu/daily-live/current/"
x=$(curl -s $mirror | grep -m1 desktop-amd64.iso | awk -F\" '{ print $2 }' | awk -F\" '{ print $1 }')
new="$mirror/$x"
output="kubuntu.iso"
checkfile $1
}

xubuntuurl () {
mirror="http://cdimage.ubuntu.com/xubuntu/daily-live/current/"
x=$(curl -s $mirror | grep -m1 desktop-amd64.iso | awk -F\" '{ print $2 }' | awk -F\" '{ print $1 }')
new="$mirror/$x"
output="xubuntu.iso"
checkfile $1
}

minturl () {
mirror="https://linuxmint.com/edition.php?id=302"
new=$(curl -s $mirror | grep -m2 iso | grep -m1 -vwE "Torrent" | awk -F"\"" '{ print $2 }')
output="linuxmint.iso"
checkfile $1
}

popurl () {
#mirror="https://fosstorrents.com/files/pop-os_22.04_amd64_intel_20.iso-hybrid.torrent"
mirrorone="https://fosstorrents.com/distributions/pop-os/"
x=$(curl -s $mirrorone | html2text | grep -m1 ".torrent)" | awk -F"(" '{ print $2 }' | awk -F")" '{ print $1 }')
mirror="https://fosstorrents.com"
new="$mirror$x"
echo "Warning! This torrent is from fosstorrents, so unofficial. And to download (aria2c) you need to install aria2."
ariacmd
checkfile $1
}

kaliurl () {
mirror="http://cdimage.kali.org/kali-weekly/"
x=$(curl -s $mirror | grep -m1 live-amd64.iso | awk -F">" '{ print $7 }' | awk -F"<" '{ print $1 }')
new="$mirror/$x"
output="kali.iso"
checkfile $1
}

parroturl () {
mirror="https://deb.parrot.sh/direct/parrot/iso/testing/"
x=$(curl -s $mirror | grep "home" | grep -m1 amd64.iso | awk -F"\"" '{ print $4 }')
new="$mirror$x"
output="parrot.iso"
checkfile $1
}

tailsurl () {
mirror="https://mirrors.edge.kernel.org/tails/stable/"
x=$(curl -s $mirror | grep tails-amd64 | awk -F "\"" '{print $2}')
new="$mirror$x"
x=$(curl -s $new | grep ".iso</a>" | awk -F "\"" '{print $2}')
new="$new$x"
output="tails.iso"
checkfile $1
}


fedoraurl () {
mirror="https://mirrors.kernel.org/fedora/releases/"
version=$(curl -s $mirror | html2text | grep -Po "\\d+\/\]" | awk -F "/" '{print $1}' | sort -n | tail -1)
mirror="$mirror$version/Workstation/x86_64/iso/"
x=$(curl -s $mirror | grep "Fedora-Workstation-Live-x86_64-$version-" | awk -F "\"" '{print $2}')
new="$mirror$x"
output="fedora.iso"
checkfile $1
}

nobaraurl () {
mirror="https://nobaraproject.org/download-nobara/"
new=$(curl -s $mirror | grep -m1 "NA Download" | awk -F"\"" '{ print $8 }')
output="nobara.iso"
checkfile $1
}

freebsdurl () {
mirror="https://www.freebsd.org/where/"
x=$(curl -s $mirror | grep -m1 "amd64/amd64" | awk -F\" '{ print $2 }')
one=$(curl -s $x | grep -m1 dvd1 | awk -F"FreeBSD" '{ print $2 }' | awk -F\" '{ print $1 }')
new=$x; new+="FreeBSD"; new+=$one; 
output="freebsd.iso"
notlinux
checkfile $1
}

netbsdurl () {
mirror="https://www.netbsd.org/" 
#mirror="https://wiki.netbsd.org/ports/amd64/"
new=$(curl -s $mirror | grep -m1 "CD" | awk -F\" '{ print $4 }')
output="netbsd.iso"
notlinux
checkfile $1
}

openbsdurl () {
mirror="https://www.openbsd.org/faq/faq4.html"
new=$(curl -s $mirror | grep -m1 -e 'iso.*amd64' | awk -F\" '{ print $2 }')
output="openbsd.iso"
notlinux
checkfile $1
}


freedosurl () {
#mirror="https://sourceforge.net/projects/freedos/files/latest/download"
#mirror="https://www.freedos.org/download/download/FD12CD.iso"
mirror="https://www.freedos.org/download/"
new=$(curl -s $mirror | grep FD13-LiveCD.zip | awk -F"\"" '{ print $2 }')
output="freedos.zip"
if [ "$1" == "filesize" ]; then 
	notlinux
	getsize
	else
 [[ ! -f $output && ! -f "freedos.img" ]] && wgetcmd && echo "Please wait, unzipping FreeDOS..." && unzip $output && sleep 10 && rm $output && rm readme.txt && mv FD13BOOT.img freedos.img && mv FD13LIVE.iso freedos.iso || echo "FreeDOS already downloaded."
fi
}

netbootxyz () {
mirror="https://boot.netboot.xyz/ipxe/netboot.xyz.iso"
new="$mirror"
output="netboot.xyz.iso"
checkfile $1
}
