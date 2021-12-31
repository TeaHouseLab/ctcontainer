function essential_mount
    logger 0 "Launching $container from $ctcontainer_root"
    function chroot_mount_ro
        for chroot_mount_target in $chroot_mount_point
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "Mounting $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target"
            end
            if grep -qs "$ctcontainer_root/$container$chroot_mount_target" /proc/mounts
            else
                sudo mount -o bind,ro $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target
            end
        end
    end
    function chroot_mount_rw
        for chroot_mount_target in $chroot_mount_point
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "Mounting $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target"
            end
            if grep -qs "$ctcontainer_root/$container$chroot_mount_target" /proc/mounts
            else
                sudo mount -o bind,rw $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target
            end
        end
    end
    setup_user_share
    switch $ctcontainer_safety_level
        case 0 -1
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 'mount in read-write filesystem'
            end
            setup_user_xorg
            setup_dbus
            set chroot_mount_point /dev /dev/pts /proc /sys
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "set mount_point.essential_mount.run_chroot -> $chroot_mount_point"
            end
            chroot_mount_rw
        case 1 2
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 'mount in read-only filesystem'
            end
            setup_user_xorg
            set chroot_mount_point /dev /dev/pts /proc /sys
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "set mount_point.essential_mount.run_chroot -> $chroot_mount_point"
            end
            chroot_mount_ro
        case h '*'
            logger 4 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
end
