function run
    set -lx container $argv[1]
    if test -d $ctcontainer_root/$container
    else
        logger 4 "No such container exist,abort,check your containerlist,or probably there's a incorrect option is providered"
        exit
    end
    if [ "$argv[2..-1]" = "" ]
        logger 4 "Nothing to run,abort"
        exit
    end
    logger 0 "Launching $container from $ctcontainer_root"
    setup_user_share
    if [ "$ctcontainer_safety_level" = 2 ]
    else
        setup_user_xorg
    end
    cd $ctcontainer_root
    if [ "$ctcontainer_safety_level" = 1 ]; or [ "$ctcontainer_safety_level" = 2 ]
        if [ "$ctcontainer_log_level" = debug ]
            logger 2 'mount in read-only filesystem'
        end
        if grep -qs "$ctcontainer_root/$container/dev" /proc/mounts
        else
            sudo mount -o bind,ro /dev $ctcontainer_root/$container/dev
        end
        if grep -qs "$ctcontainer_root/$container/dev/pts" /proc/mounts
        else
            sudo mount -o bind /dev/pts $ctcontainer_root/$container/dev/pts
        end
        if grep -qs "$ctcontainer_root/$container/proc" /proc/mounts
        else
            sudo mount -o bind,ro /proc $ctcontainer_root/$container/proc
        end
        if grep -qs "$ctcontainer_root/$container/sys" /proc/mounts
        else
            sudo mount -o bind,ro /sys $ctcontainer_root/$container/sys
        end
    else
        if [ "$ctcontainer_log_level" = debug ]
            logger 2 'mount in read-write filesystem'
        end
        if grep -qs "$ctcontainer_root/$container/dev" /proc/mounts
        else
            sudo mount -o bind,rw /dev $ctcontainer_root/$container/dev
        end
        if grep -qs "$ctcontainer_root/$container/dev/pts" /proc/mounts
        else
            sudo mount -o bind /dev/pts $ctcontainer_root/$container/dev/pts
        end
        if grep -qs "$ctcontainer_root/$container/proc" /proc/mounts
        else
            sudo mount -o bind,rw /proc $ctcontainer_root/$container/proc
        end
        if grep -qs "$ctcontainer_root/$container/sys" /proc/mounts
        else
            sudo mount -o bind,rw /sys $ctcontainer_root/$container/sys
        end
    end
    if [ "$ctcontainer_safety_level" = 2 ]
        sudo chroot --userspec safety:safety $container env HOME=/home/safety DISPLAY=:0 $argv[2..-1]
    else
        sudo chroot $container env DISPLAY=:0 $argv[2..-1]
    end
    if [ "$ctcontainer_auto_umount" = 1 ]
        sudo umount -l $ctcontainer_root/$container/dev
        sudo umount -l $ctcontainer_root/$container/proc
        sudo umount -l $ctcontainer_root/$container/sys
        if grep -qs "$ctcontainer_root/$container/tmp/.X11-unix" /proc/mounts
            sudo umount -l $ctcontainer_root/$container/tmp/.X11-unix
        end
        sudo umount -l $ctcontainer_root/$container/ctcontainer_share
        logger 0 Umountd
    else
        logger 3 "Do you want to umount bind mounts(if another same container is running,choose no)[y/n]"
        read -n1 -P "$prefix >>> " _umount_
        switch $_umount_
            case n N
                logger 0 "I'm not going to umount it,exit chroot only"
            case y Y '*'
                sudo umount -l $ctcontainer_root/$container/dev
                sudo umount -l $ctcontainer_root/$container/proc
                sudo umount -l $ctcontainer_root/$container/sys
                if grep -qs "$ctcontainer_root/$container/tmp/.X11-unix" /proc/mounts
                    sudo umount -l $ctcontainer_root/$container/tmp/.X11-unix
                end
                sudo umount -l $ctcontainer_root/$container/ctcontainer_share
                logger 0 Umountd
        end
    end
end
