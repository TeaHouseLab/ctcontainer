function nspawn_run
    argparse -i -n $prefix 'o/port=' -- $argv
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
            setup_network
            if set -q _flag_port
                set port_range $_flag_port
                if echo $port_range | grep -qs -
                    set -e port_mapping_tcp
                    set -e port_mapping_udp
                    set -e port_mapping
                    set port_counter 0
                    for port_arrary in (seq (echo $port_range | awk -F "-" '{print $1}') (echo $port_range | awk -F "-" '{print $2}'))
                        set port_counter (math $port_counter+1)
                        set port_mapping_tcp[$port_counter] "-ptcp:$port_arrary"
                        set port_mapping_udp[$port_counter] "-pudp:$port_arrary"
                    end
                else
                    if echo $port_range | grep -qs ,
                        set -e port_mapping_tcp
                        set -e port_mapping_udp
                        set -e port_mapping
                        set port_counter 0
                        for port_arrary in (echo $port_range | string split ,)
                            set port_counter (math $port_counter+1)
                            set port_mapping_tcp[$port_counter] "-ptcp:$port_arrary"
                            set port_mapping_udp[$port_counter] "-pudp:$port_arrary"
                        end
                    else
                        set port_mapping_tcp "-ptcp:$_flag_port"
                        set port_mapping_udp "-pudp:$_flag_port"
                    end
                end
                sudo systemd-nspawn --resolv-conf=off $port_mapping_tcp $port_mapping_udp -bnq -D $container
            else
                sudo systemd-nspawn --resolv-conf=off -bnq -D $container
            end
        case 1
            sudo systemd-nspawn --resolv-conf=off -q -D $container env DISPLAY=:0 $argv[2..-1]
        case 2
            sudo systemd-nspawn --resolv-conf=off -q -u safety -D $container env DISPLAY=:0 HOME=/home/safety USER=safety $argv[2..-1]
        case h '*'
            logger 5 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
end
