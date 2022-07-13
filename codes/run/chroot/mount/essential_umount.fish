function essential_umount
    function chroot_umount
        set chroot_mount_point /dev/pts /dev /proc /sys /var/run/dbus /tmp/run/dbus /run/dbus "$XDG_RUNTIME_DIR" /ctcontainer_share
        for chroot_umount_target in $chroot_mount_point
            if grep -qs "$ctcontainer_root/$container$chroot_umount_target" /proc/mounts
                sudo umount -l $ctcontainer_root/$container$chroot_umount_target
            end
        end
        if grep -qs /dev/pts /proc/mounts
        else
            sudo mount devpts /dev/pts -t devpts
        end
        logger 1 Umountd
    end
    switch $ctcontainer_auto_umount
        case 0
            logger 1 "Exited without umount"
        case 1 '*'
            chroot_umount
    end
end
