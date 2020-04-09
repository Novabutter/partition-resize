#!/bin/bash
## THIS IS SPECIFICALLY FOR THE SEMO CYBER RANGE KALI LINUX 2019 BOXES
# RUN AS ROOT
swapoff -a
#for loop, check confirmation, if wrong repeat and search for next drive
DRIVE=$(ls /dev | awk '/da/ {print $0}' | awk 'FNR == 1 {print}')
#read -p for confirmation instead of below line.
MAIN_DRIVE="/dev/$DRIVE"
echo "Using $MAIN_DRIVE"


# Assumes Gigabytes
declare -i TOTAL_SPACE=$(fdisk -l | grep $DRIVE | cut -d':' -f2 | cut -d',' -f1 | cut -d' ' -f2 | awk 'FNR == 1 {print}')
STORAGE=$((TOTAL_SPACE - 4))
# Save 2 GB just in case. No need really.
SWAP=2
sed -i 's/+G/+'$STORAGE'G/g' import.txt
sed -i 's/++G/+'$SWAP'G/g' import.txt

cat import.txt | fdisk $MAIN_DRIVE

partprobe
resize2fs $MAIN_DRIVE"1"
mkswap $MAIN_DRIVE"2"
SWAP_UUID=$(blkid | grep "swap" | awk '/UUID="*"/ {print $2}' | cut -d'"' -f2)
ORIG_UUID=$(cat /etc/fstab | grep swap | cut -d'=' -f2 | cut -d' ' -f1 | awk 'FNR == 2 {print}')
sed -i '/^.*swap*/s/UUID='$ORIG_UUID'/UUID='$SWAP_UUID'/g' /etc/fstab
swapon -a