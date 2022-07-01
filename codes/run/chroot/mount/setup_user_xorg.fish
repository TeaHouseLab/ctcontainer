function setup_user_xorg
    switch $ctcontainer_x11
        case xhost
            if command -q -v xhost
                if xhost +local: &>/dev/null
                else
                    if [ "$ctcontainer_log_level" = debug ]
                        logger 3 "Xhost cannot be setup,skip"
                    end
                end
            else
                if [ "$ctcontainer_log_level" = debug ]
                    logger 3 "Xhost was not found,xorg in container couldn't be set up"
                end
            end
        case xephyr
            if command -q -v Xephyr
                Xephyr -br -ac -noreset -title "ctcontainer@$container" :1 &>/dev/null &
            else
                if [ "$ctcontainer_log_level" = debug ]
                    logger 3 "Xephyr was not found,xorg in container couldn't be set up"
                end
            end
        case '*'
            logger 4 "Skip setup for x11"
    end
end
