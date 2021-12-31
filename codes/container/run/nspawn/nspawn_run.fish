function nspawn_run
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
    setup_dir_nspawn
    cd $ctcontainer_root
    essential_mount
    switch $ctcontainer_safety_level
        case -1
            sudo systemd-nspawn -q -u safety -D $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/home/safety USER=safety $argv[2..-1]
        case 0
            sudo systemd-nspawn -b -q -D $container
        case 1
            sudo systemd-nspawn -q -D $container env DISPLAY=:0 $argv[2..-1]
        case 2
            sudo systemd-nspawn -q -u safety -D $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/home/safety USER=safety $argv[2..-1]
        case h '*'
            logger 4 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
    essential_umount
end
