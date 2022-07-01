function purge
    for container in $argv[1..-1]
        cd $ctcontainer_root
        if test -d $container
            if sudo rm -rf $container
                logger 2 "$container has been purged"
            else
                logger 5 "Something went wrong while purging $container"
            end
        else
            logger 5 "Container $container does not exist,abort,check your containerlist,or probably there's a incorrect option is provided"
            exit
        end
    end
end
