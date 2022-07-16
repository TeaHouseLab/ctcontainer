function purge
    set -lx container
    for container in $argv[1..-1]
        container_tester $container
        cd $ctcontainer_root
        if grep -qs "$ctcontainer_root/$container" /proc/mounts
            logger 3 "A container is running, Umount and purge it?[y/n]"
            read -n1 -P "$prefix >>> " _purge_
            switch $_purge_
                case y Y
                    set ctcontainer_auto_umount 1
                    essential_umount
                case n N '*'
                    logger 1 Abort
                    exit
            end
        end
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
