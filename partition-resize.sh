#!/bin/bash
# RUN AS ROOT
swapoff -a
#for loop, check confirmation, if wrong repeat and search for next drive
DRIVE=$(ls /dev | awk '/da/ {print $0}' | awk 'FNR == 1 {print}')
#read -p for confirmation instead of below line.
MAIN_DRIVE="/dev/$DRIVE"
echo "Using $MAIN_DRIVE"

# Assumes Gigabytes
declare -i TOTAL_SPACE=$(fdisk -l | grep $DRIVE | cut -d':' -f2 | cut -d',' -f1 | cut -d' ' -f2 | awk 'FNR == 1 {print}')
STORAGE="+"$((TOTAL_SPACE - 4))"G"
# Save 2 GB just in case. No need really.
SWAP="+""2""G"

(echo p; echo d; echo 5; echo d; echo 1; echo d; echo n; echo p; echo 1; echo ""; echo $STORAGE; echo "Y"; echo n; echo p; echo 2; echo ""; echo $SWAP; echo t; echo 2; echo 82; echo w; echo p) | fdisk $MAIN_DRIVE

partprobe
resize2fs $MAIN_DRIVE"1"
mkswap $MAIN_DRIVE"2"
SWAP_UUID=$(blkid | grep "swap" | awk '/UUID="*"/ {print $2}' | cut -d'"' -f2)
ORIG_UUID=$(cat /etc/fstab | grep swap | cut -d'=' -f2 | cut -d' ' -f1 | awk 'FNR == 2 {print}')
sed -i '/^.*swap*/s/UUID='$ORIG_UUID'/UUID='$SWAP_UUID'/g' /etc/fstab
swapon -a