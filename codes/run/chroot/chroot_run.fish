function chroot_run
    set -lx container $argv[1]
    set -lx chroot_mount_point
    if [ "$ctload" = "true" ]
        cd (dirname $argv[1])
        set ctcontainer_root .
        set container (basename $argv[1])
    end
    if test -d $ctcontainer_root/$container
    else
        logger 5 "Container $container does not exist,abort,check your containerlist,or probably there's a incorrect option is provided"
        exit
    end
    if [ "$argv[2..-1]" = "" ]
        logger 5 "Nothing to run,abort"
        exit
    end
    cd $ctcontainer_root
    essential_mount
    switch $ctcontainer_safety_level
        case -1
            sudo unshare -impuCTf chroot --userspec safety:safety $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR DISPLAY=:0 HOME=/home/safety USER=safety $argv[2..-1]
        case 0
            sudo unshare -impuCTf chroot $container env DISPLAY=:0 XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR $argv[2..-1]
        case 1
            sudo unshare -impuCTf chroot $container env DISPLAY=:0 $argv[2..-1]
        case 2
            sudo unshare -impuCTf chroot --userspec safety:safety $container env DISPLAY=:0 HOME=/home/safety USER=safety $argv[2..-1]
        case h '*'
            logger 5 "Can't understand what is safety_level.ctcontainer{$ctcontainer_safety_level},abort"
            exit
    end
    essential_umount
end
