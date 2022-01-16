function setup_user_xorg
    if command -q -v xhost
        if xhost +local: &>/dev/null
        else
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "Xhost cannot be launched,skip"
            end
        end
    else
        if [ "$ctcontainer_log_level" = debug ]
            logger 2 "$prefix [error] Xhost not found,xorg in container couldn't be set up"
        end
    end
end
