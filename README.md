## iso-downloader
Bash script for autodownloading of different linux distros, bsd distros or other OSes useful for diagnostics etc.

## Requirements: 
* Basic stuff: `linux`, `bash`, `curl`, `wget`, `awk`, `grep`, `xargs`, `pr`, `tail`, `sort` (these tools usually are preinstalled on linux)
* Additional depencency: `html2text`
* Install all deps on Arch-based distro: `sudo pacman -S html2text`
* Some systems are shared as archive so you'll need `unzip`

## Currently supported systems
```
Arch-based:		    DEB-based:			RPM-based:		    BSD:			Other:		Not linux:
0 = archlinux		    2 = debian			12 = fedora		    14 = freebsd		17 = memtest64bit	20 = freedos
1 = endeavour		    3 = debian_testing		13 = nobara		    15 = netbsd			18 = memtest32bit	
			    4 = ubuntu						    16 = openbsd		19 = antiviruslive	
			    5 = kubuntu						    						
			    6 = xubuntu						    						
			    7 = linuxmint					    						
			    8 = popos						    						
			    9 = kali						    						
			    10 = parrot						    						
			    11 = tails
```

## How to use?
1. `git clone https://github.com/k0ss4/iso-downloader`
2. `cd iso-downloader`
3. `./download.sh`
Then you have couple of options:
* download one ISO (e.g. type 0 for archlinux)*
* download several ISOs - space separated (e.g. for getting both Arch and Endeavour, type '0 1' (without quotes))*
* 'all' option, the script will download ALL of the ISOs (warning: this can take a lot of space as well as several hours to download everything!)
* 'filesize' option will check the local (downloaded) filesizes of ISOs vs. the current/recent ISOs filesizes on the websites
* 'netbootxyz' option allows you to boot from netboot.xyz via network

## Files descriptions
* download.sh is in the main script
* systemfunctions.sh contains all URL/mirror/HTTP scraping stuff

## Author & License
* Written by SecurityXIII
* Modified by K0SS4
* Project began in August 2020 - but since then improved several times
* Kopimi un-license as well as MIT
