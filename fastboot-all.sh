# Copyright (c) 2015 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.

adb reboot bootloader
[ -e boot.img          ] && fastboot flash boot boot.img
[ -e cache.img         ] && fastboot flash cache cache.img
[ -e system.img        ] && fastboot flash system system.img
[ -e userdata.img      ] && fastboot flash userdata userdata.img
[ -e recovery.img      ] && fastboot flash recovery recovery.img
#[ -e persist.img       ] && fastboot flash persist persist.img
#[ -e update.img        ] && fastboot flash update update.img
#[ -e emmc_appsboot.mbn ] && fastboot flash aboot emmc_appsboot.mbn
fastboot reboot
echo Flashing done, rebooting...
