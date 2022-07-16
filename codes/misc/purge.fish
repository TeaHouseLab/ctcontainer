function purge
    for container in $argv[1..-1]
        container_tester $container
        cd $ctcontainer_root
        if test -e /etc/systemd/system/ctcontainer-$container.service
            service remove $container
        end
        if sudo rm -rf -- $container
            logger 2 "$container has been purged"
        else
            logger 5 "Something went wrong while purging $container"
        end
    end
end
