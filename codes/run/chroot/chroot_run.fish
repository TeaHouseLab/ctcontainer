function chroot_run
    set -lx container $argv[1]
    set -lx chroot_mount_point
    if test -d $ctcontainer_root/$container
    else
        logger 4 "No such container exist,abort,check your containerlist,or probably there's a incorrect option is providered"
        exit
    end
    if [ "$argv[2..-1]" = "" ]
        logger 4 "Nothing to run,abort"
        exit
    end
    cd $ctcontainer_root
    essential_mount
    switch $ctcontainer_safety_level
        case -1
            sudo chroot --userspec safety:safety $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/home/safety USER=safety $argv[2..-1]
        case 0
            sudo chroot $container env DISPLAY=:0 XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR $argv[2..-1]
        case 1
            sudo chroot $container env DISPLAY=:0 $argv[2..-1]
        case 2
            sudo chroot --userspec safety:safety $container env HOME=/home/safety USER=safety $argv[2..-1]
        case h '*'
            logger 4 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
    essential_umount
end
