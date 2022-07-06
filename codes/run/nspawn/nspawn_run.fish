function nspawn_run
    set -lx container $argv[1]
    if [ "$ctload" = true ]
        cd (dirname $argv[1])
        set ctcontainer_root .
        set container (basename $argv[1])
    end
    if test -d $ctcontainer_root/$container
    else
        logger 5 "No such container exist,abort,check your containerlist,or probably there's a incorrect option is providered"
        exit
    end
    if [ "$argv[2..-1]" = "" ]
        if test "$ctcontainer_safety_level" = 0
        else
            logger 5 "Nothing to run,abort"
            exit
        end
    end
    setup_dir_nspawn
    setup_user_xorg
    cd $ctcontainer_root
    switch $ctcontainer_safety_level
        case -1
            sudo systemd-nspawn --resolv-conf=off --bind=$ctcontainer_share:/ctcontainer_share -q -u safety -D $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR DISPLAY=:0 HOME=/home/safety USER=safety $argv[2..-1]
        case 0
            sudo systemd-nspawn --resolv-conf=off -b -q -D $container
        case 1
            sudo systemd-nspawn --resolv-conf=off -q -D $container env DISPLAY=:0 $argv[2..-1]
        case 2
            sudo systemd-nspawn --resolv-conf=off -q -u safety -D $container env DISPLAY=:0 HOME=/home/safety USER=safety $argv[2..-1]
        case h '*'
            logger 5 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
end
