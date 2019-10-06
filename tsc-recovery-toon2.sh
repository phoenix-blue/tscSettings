usertouch()
{
        local TIMEOUT=$1

        # fork an input consumer process
        (cat /dev/input/event1 > /tmp/usertouch.txt) 2>/dev/null &
        local TPID=$!

        for i in $(seq $TIMEOUT); do
                [ "$(stat -c %s /tmp/usertouch.txt)" = "0" ] || break
                sleep 1
        done

        kill -9 $TPID

        local SIZE=$(stat -c %s /tmp/usertouch.txt; rm -f /tmp/usertouch.txt)
        [ "$SIZE" != "0" ]
        return $?
}

write_image()
{
        userlog "Writing bootfs..."
        zcat /tmp/bootfs.img.gz | dd of=/dev/mmcblk3p1 bs=1M conv=fsync || return $?

        userlog "Writing rootfs..."
        zcat /tmp/rootfs.img.gz | dd of=/dev/mmcblk3p2 bs=1M conv=fsync || return $?

        userlog "Resizing rootfs..."
        resize2fs /dev/mmcblk3p2 || return $?
		sync ; sync ; sync
}

patch_root_access()
{
	
	mount -o rw LABEL=system /mnt/system || userlog "Unable to mount SYS fs"
	
	userlog "Setting root password to toon"
	sed -i 's/root:[^:]*/root:FTR0zlZvsHEF2/' /mnt/system/etc/shadow

	userlog "Patching firewall for SSH and HTTP access"
	sed -i 's/^#-A/-A/' /mnt/system/etc/default/iptables.conf

	userlog "Disable Eneco VPN"
	sed -i 's~ovpn:235~#ovpn:235~g' /mnt/system/etc/inittab


	userlog "Placing a dropbear-install-and-updatesscript-on-boot script"
	cat <<'EOT' > /mnt/system/etc/rc5.d/S99dropbear-install-and-update.sh
#!/bin/sh

usertouch()
{
        local TIMEOUT=$1

        # fork an input consumer process
        (cat /dev/input/event1 > /tmp/usertouch.txt) 2>/dev/null &
        local TPID=$!

        for i in $(seq $TIMEOUT); do
                [ "$(stat -c %s /tmp/usertouch.txt)" = "0" ] || break
                sleep 1
        done

        kill -9 $TPID

        local SIZE=$(stat -c %s /tmp/usertouch.txt; rm -f /tmp/usertouch.txt)
        [ "$SIZE" != "0" ]
        return $?
}

userlog()
{
        echo "$@" | tee -a /dev/tty0
}

main ()
{
        #on toon2 recovery the wifi settings will still work so eventually this while loop should work
        while ! opkg install http://qutility.nl/dropbear_2014.66-r0_cortexa9hf-vfp-neon.ipk
        do
                sleep 10
        done
        #after that downloading the update script should work also
        curl -Nks https://raw.githubusercontent.com/ToonSoftwareCollective/update-rooted/master/update-rooted.sh -o /root/update-rooted.sh

	#now it is time to stop running processes and set the screen to show console output
        /etc/init.d/HCBv2 stop
        # prevent restarting during upgrade
        echo 'exit' > /tmp/etc-default-HCBv2
        chmod a+x /tmp/etc-default-HCBv2

        killall -9 hcb_netcon
        echo ">> Disabling watchdog /dev/watchdog"
        rm -f /dev/watchdog
        mknod /dev/watchdog c 10 130
        # make sure we don't reboot:
        echo V > /dev/watchdog
        rm -f /dev/watchdog

        killall -19 qt-gui

        # psplash runs without -n so we need to stop it to show console
        TMPDIR=/mnt/.psplash psplash-write "QUIT"
        # setting mode reinits the console (and with it wipes the background)
        cat /sys/class/graphics/fb0/modes > /sys/class/graphics/fb0/mode
        # unblank
        echo 0 > /sys/class/graphics/fb0/blank
        # turn off blanking timeouts for terminal
        echo -n -e '\033[9;0]\033[14;0]'> /dev/tty0
        # clear screen
        echo -n -e '\033[2J'> /dev/tty0

        #remove this startup file so it doesnt start again
        rm /etc/rc5.d/S99dropbear-install-and-update.sh

	IP=`ip addr show dev wlan0 | grep inet |  awk '{print $2}' | cut -d\/ -f1`
	userlog "****                   Welcome to the after-recovery TSC routine                     ****"
	userlog "* Toon IP addres: $IP"
	userlog "* Toon password : toon"
	userlog "* Toon SSH      : enabled"
	userlog "**** Touch the screen within 10 seconds to cancel the auto update to latest firmware ****"

	if usertouch 10; then
        	userlog "Canceled auto update. SSH is enabled. It is now up to you :-)"
	else
        	#finallly start the unconditional update and output to screen
        	sh /root/update-rooted.sh -u > /dev/tty0
	fi
}

main 2&>1 > /qmf/www/rsrc/log &
EOT


	chmod +x /mnt/system/etc/rc5.d/S99dropbear-install-and-update.sh
	
	umount /mnt/system || userlog "Unable to umount SYS fs"

    sync ; sync ; sync
}

prepare_image()
{
	userlog "Unpacking /mnt/recovery/recovery-image.zip to /tmp folder"
	mount -o rw LABEL=recovery /mnt/recovery || userlog "Unable to mount RECOVERY fs"
	if ! unzip -p "/mnt/recovery/recovery-image.zip" "*bootfs.*.gz" > /tmp/bootfs.img.gz; then
		userlog "Failed unpacking bootfs.img.gz"
		return 1
	fi
	if ! unzip -p "/mnt/recovery/recovery-image.zip" "*rootfs.*.gz" > /tmp/rootfs.img.gz; then
		userlog "Failed unpacking rootfs.img.gz"
		return 1
	fi
	umount /mnt/recovery || userlog "Unable to umount RECOVERY fs"

}

enableBacklight()
{
        cat /sys/class/backlight/mp3309-bl/max_brightness > /sys/class/backlight/mp3309-bl/brightness
}

reboot()
{
        echo b > /proc/sysrq-trigger
        sleep 15
        echo "Reboot failed."
        return 1
}

userlog()
{
        echo "$@" | tee -a /dev/tty0
}


enableBacklight
userlog "Restoring toon, the TSC way! Touch the screen to start the TSC recovery procedure or wait 10 seconds to skip..."

if usertouch 10; then
    prepare_image
    userlog "Recovery image flashing starts"
    if write_image; then
		patch_root_access
		userlog "Recovery completed. Follow the one-time-boot scripts for installing dropbear and auto update on http://toon-ip/rsrc/log during toon boot"
		userlog "Touch the screen to reboot or wait 30 seconds"
		usertouch 30
		reboot
	else
		userlog "Writing recovery image failed!"
    fi
else
    userlog "TSC recovery procedure skipped."
fi
