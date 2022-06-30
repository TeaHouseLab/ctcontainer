function list
    switch $argv[1]
        case installed
            switch $argv[2]
                case size
                    logger 1 "Installed"
                    for container in (list_menu $ctcontainer_root)
                        printf "$container "
                        sudo du -sh $ctcontainer_root/$container | awk '{ print $1 }'
                    end
                case '*'
                    logger 1 "Installed"
                    list_menu $ctcontainer_root
            end
        case available
            logger 1 "Available"
            curl -s -L https://cdngit.ruzhtw.top/ctcontainer/available
        case '*'
            logger 1 "Available"
            curl -s -L https://cdngit.ruzhtw.top/ctcontainer/available
            echo
            logger 1 "Installed"
            list_menu $ctcontainer_root
    end
end
