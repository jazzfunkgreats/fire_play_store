#!/bin/bash

####################################################################
#
#   fire_play_store.sh
#
#   Author:
#       jazzfunkgreats
#
#   Description:
#       A script to install the Google Play apps on an Amazon Fire
#       (5th Gen, 2015) tablet, as well as enable/disable Amazon
#       auto-updates.
#
####################################################################

# 1. CHECK IF ADB IS INSTALLED
echo "Checking if adb is installed..."

type adb >/dev/null 2>&1 || { 
    echo "adb not installed - please run the following commands (if running Ubuntu) to install it:" 
    echo ""
    echo "$ sudo add-apt-repository ppa:phablet-team/tools && sudo apt-get update"
    echo "$ sudo apt-get install android-tools-adb android-tools-fastboot"
    echo ""
    echo "Other distros should consult Google for adb installation instructions."
    exit 1; 
}

echo "adb seems to already be installed!"
echo ""
adb kill-server
adb start-server

cat<<EOF
------------------------------------------------------------------------------
Before continuing, please turn on ADB DEBUGGING in your Amazon Fire settings:
Go to device options, then press the serial number 7 times to enable
Developer Options. In Developer Options, turn on the 'Enable adb' option.
------------------------------------------------------------------------------
EOF
read -n1 -r -p "Press any key to continue..." key


# 2. MENU SELECTION
while :
do
    clear
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
    echo "  Amazon Fire Google Play Apps Installer - Main Menu"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
    cat<<EOF
    Please enter your choice:

    (1) Install Google Play apps
    (2) Block Amazon OTA updates
    (3) Unblock Amazon OTA updates

    (Q)uit
EOF
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    read -n1 -s
    case "$REPLY" in

# 3. (1) GOOGLE PLAY INSTALLER
    "1")  echo "" 
          read -n1 -r -p "Ready to install Google Play Store apps, press any key..." key          
          adb wait-for-devices
          echo "##### Installing app 1 of 4 #####"
          adb install com.google.android.gms-6.6.03_\(1681564-036\)-6603036-minAPI9.apk
          echo "##### Installing app 2 of 4 #####"
          adb install GoogleLoginService.apk
          echo "##### Installing app 3 of 4 #####"
          adb install GoogleServicesFramework.apk
          adb shell pm grant com.google.android.gms android.permission.INTERACT_ACROSS_USERS
          echo "##### Installing app 4 of 4 #####"
          adb install com.android.vending-5.9.12-80391200-minAPI9.apk
          adb shell pm hide com.amazon.kindle.kso
          adb kill-server        
          echo ""
          echo "All apps installed and permissions set!"
          echo "Please reboot Amazon Fire device to remove ads, then sign into the Play Store."
          echo ""
          read -n1 -r -p "Press any key to return to the main menu."
          ;;

# 4. (2) BLOCK AMAZON OTA UPDATES
    "2")  echo ""
          read -n1 -r -p "Ready to block Amazon auto-updates, press any key..." key
          adb wait-for-devices
          adb shell pm hide com.amazon.otaverifier
          adb shell pm hide com.amazon.device.software.ota
          adb shell pm hide com.amazon.settings.systemupdates 
          adb kill-server
          echo ""
          echo "Amazon OTA auto-updates have now been blocked."
          echo ""
          read -n1 -r -p "Press any key to return to the main menu."
         ;;

# 5. (3) UNBLOCK AMAZON OTA UPDATES
    "3")  echo "you chose choice 3" 
          read -n1 -r -p "Ready to unblock Amazon auto-updates, press any key..." key
          adb wait-for-devices
          adb shell pm unhide com.amazon.otaverifier
          adb shell pm unhide com.amazon.device.software.ota
          adb shell pm unhide com.amazon.settings.systemupdates 
          adb kill-server
          echo ""
          echo "Amazon OTA auto-updates have now been unblocked."
          echo ""
          read -n1 -r -p "Press any key to return to the main menu."
         ;;

    "Q")  exit                      ;;
    "q")  exit                      ;; 
     * )  echo  "invalid option"    ;;
    esac
    sleep 1
done    

