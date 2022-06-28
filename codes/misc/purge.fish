function purge
    for container in $argv[1..-1]
        cd $ctcontainer_root
        if test -d $container
            if sudo rm -rf $container
                logger 2 "$container has been purged"
            else
                logger 5 "Ouch!Something went wrong at purge.ctcontainer"
            end
        else
            logger 5 "No such container in root.ctcontainer"
        end
    end
end
