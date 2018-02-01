#!/bin/bash
#===============================================================================
#
# macapps.sh --- application installer for macOS
#
# Original work by Rubén del Campo available at https://macapps.link/.
# This script installs and updates macOS applications.
#
# Usage:
#   sh macapps.sh
#
# TODO:
#  - Query user for new URL if download fails.
#  - Add apps:
#    - Pocket
#    - Google Drive ?
#    - Dropbox
#    - Clementine
#    - Audacity
#    - XLD
#    - VirtualBox
#    - The Unarchiver
#    - KeePassX
#    - TomTom Sports
#    - Keybase
#    - Shiba
#    - iReal Pro
#    - Signal
#    - Hugin
#    - Transcribe ?
#    - ZOOM Edit&Share ?
#    - GPG
#    - Chrome
#    - CHM View and CHM-to-PDF ?
#    - XPS-to-PDF Lite ?
#
#===============================================================================
set -eu

clear && rm -rf /tmp/macapps && mkdir /tmp/macapps > /dev/null && pushd /tmp/macapps


###############################
#    Print script header      #
###############################
echo $"
Originally by
 ███╗   ███╗ █████╗  ██████╗ █████╗ ██████╗ ██████╗ ███████╗
 ████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝
 ██╔████╔██║███████║██║     ███████║██████╔╝██████╔╝███████╗
 ██║╚██╔╝██║██╔══██║██║     ██╔══██║██╔═══╝ ██╔═══╝ ╚════██║
 ██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║     ██║     ███████║╔═════════╗
 ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═ .link ═╝\n"


###############################
#    Define worker functions  #
###############################
versionChecker() {
  local v1=$1; local v2=$2;
  while [ `echo $v1 | egrep -c [^0123456789.]` -gt 0 ]; do
    char=`echo $v1 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v1=`echo $v1 | sed "s/$char/.$char_dec/g"`; done
  while [ `echo $v2 | egrep -c [^0123456789.]` -gt 0 ]; do
    char=`echo $v2 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v2=`echo $v2 | sed "s/$char/.$char_dec/g"`; done
  v1=`echo $v1 | sed 's/\.\./.0/g'`; v2=`echo $v2 | sed 's/\.\./.0/g'`;
  checkVersion "$v1" "$v2"
}


checkVersion() {
  [ "$1" == "$2" ] && return 1
  v1f=`echo $1 | cut -d "." -f -1`;v1b=`echo $1 | cut -d "." -f 2-`;v2f=`echo $2 | cut -d "." -f -1`;v2b=`echo $2 | cut -d "." -f 2-`;
  if [[ "$v1f" != "$1" ]] || [[ "$v2f" != "$2" ]]; then
    [[ "$v1f" -gt "$v2f" ]] && return 1; [[ "$v1f" -lt "$v2f" ]] && return 0;
    [[ "$v1f" == "$1" ]] || [[ -z "$v1b" ]] && v1b=0; [[ "$v2f" == "$2" ]] || [[ -z "$v2b" ]] && v2b=0; checkVersion "$v1b" "$v2b"; return $?
  else [ "$1" -gt "$2" ] && return 1 || return 0; fi
}


appStatus() {
  if [ ! -d "/Applications/$1" ]; then echo "uninstalled"; else
    if [[ $5 == "build" ]]; then BUNDLE="CFBundleVersion"; else BUNDLE="CFBundleShortVersionString"; fi
    INSTALLED=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Applications/$1/Contents/Info.plist"`
      if [ $4 == "dmg" ]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Volumes/$2/$1/Contents/Info.plist"`;
      elif [[ $4 == "zip" || $4 == "tar" ]]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "$3$1/Contents/Info.plist"`; fi
    checkVersion "$INSTALLED" "$COMPARETO"; UPDATED=$?;
    if [[ $UPDATED == 1 ]]; then echo "updated"; else echo "outdated"; fi; fi
}


installApp() {
  echo $'\360\237\214\200  - ['$2'] Downloading app...'
  if [ $1 == "dmg" ]; then curl -s -L -o "$2.dmg" $4; yes | hdiutil mount -nobrowse "$2.dmg" -mountpoint "/Volumes/$2" > /dev/null;
    if [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "/Volumes/$2/$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "uninstalled" ]]; then cp -R "/Volumes/$2/$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    hdiutil unmount "/Volumes/$2" > /dev/null && rm "$2.dmg"
  elif [ $1 == "zip" ]; then curl -s -L -o "$2.zip" $4; unzip -qq "$2.zip";
    if [[ $(appStatus "$3" "" "$5" "zip" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$5$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi;
    rm -rf "$2.zip" && rm -rf "$5" && rm -rf "$3"
  elif [ $1 == "tar" ]; then curl -s -L -o "$2.tar.bz2" $4; tar -zxf "$2.tar.bz2" > /dev/null;
    if [[ $(appStatus "$3" "" "$5" "tar" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    rm -rf "$2.tar.bz2" && rm -rf "$3"; fi
}


###############################
#    Install selected apps    #
###############################
# installApp "dmg" "Firefox"     "Firefox.app"        "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-UK" "" "" ""
# installApp "dmg" "GIMP"        "GIMP.app"           "http://download.gimp.org/mirror/pub/gimp/v2.8/osx/gimp-2.8.22-x86_64.dmg" "" "" ""
# installApp "dmg" "Slack"       "Slack.app"          "https://slack.com/ssb/download-osx" "" "" ""
# installApp "dmg" "Skype"       "Skype.app"          "http://www.skype.com/go/getskype-macosx.dmg" "" "" ""
installApp "dmg" "Sync"        "Resilio Sync.app"   "https://download-cdn.resilio.com/stable/osx/Resilio-Sync.dmg" "" "" ""
# installApp "dmg" "Thunderbird" "Thunderbird.app"    "http://download.mozilla.org/?product=thunderbird-latest&os=osx&lang=en-UK" "" "" ""
# installApp "dmg" "TorBrowser"  "TorBrowser.app"     "https://www.torproject.org/dist/torbrowser/7.0.11/TorBrowser-7.0.11-osx64_en-UK.dmg" "" "" ""
# installApp "dmg" "VLC"         "VLC.app"            "http://get.videolan.org/vlc/2.2.8/macosx/vlc-2.2.8.dmg" "" "" ""
installApp "zip" "Amethyst"    "Amethyst.app"       "http://ianyh.com/amethyst/versions/Amethyst-latest.zip" "" "" ""
# installApp "zip" "Flux"        "Flux.app"           "https://justgetflux.com/mac/Flux.zip" "" "" "build"
# installApp "zip" "GitHub"      "GitHub Desktop.app" "https://central.github.com/deployments/desktop/desktop/latest/darwin" "" "" ""
# installApp "zip" "OpenEmu"     "OpenEmu.app"        "https://github.com/OpenEmu/OpenEmu/releases/download/v2.0.6.1/OpenEmu_2.0.6.1.zip" "" "" "build"
# installApp "zip" "Spectacle"   "Spectacle.app"      "https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip" "" "" ""
# installApp "zip" "iTerm2"      "iTerm.app"          "https://iterm2.com/downloads/stable/latest" "" "" ""

# For home use only
# installApp "dmg" "LibreOffice"  "LibreOffice.app"  "http://download.documentfoundation.org/libreoffice/stable/6.0.0/mac/x86_64/LibreOffice_6.0.0_MacOS_x86-64.dmg" "" "" ""
# installApp "dmg" "Transmission" "Transmission.app" "https://github.com/transmission/transmission-releases/raw/master/Transmission-2.92.dmg" "" "" ""
# installApp "dmg" "Tunnelblick"  "Tunnelblick.app"  "https://tunnelblick.net/release/Tunnelblick_3.7.5beta05_build_4980.dmg" "" "" ""
# installApp "dmg" "KeePassX"     "KeePassX.app"     "http://www.keepassx.org/releases/2.0.3/KeePassX-2.0.3.dmg" "" "" ""
# installApp "zip" "OpenEmu"      "OpenEmu.app"      "https://github.com/OpenEmu/OpenEmu/releases/download/v2.0.6.1/OpenEmu_2.0.6.1.zip" "" "" "build"
# installApp "dmg" "Steam"        "Steam.app"        "http://media.steampowered.com/client/installer/steam.dmg" "" "" "build"


###############################
#    Print script footer      #
###############################
echo $'------------------------------------------------------------------------------'
echo $'\360\237\222\254   We are done.'
echo $'------------------------------------------------------------------------------\n'
popd
# macapps.sh ends here
