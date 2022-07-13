function list
    set images (curl -sL $ctcontainer_source/streams/v1/images.json | jq -r '.products')
    switch $argv[1]
        case installed
            switch $argv[2]
                case size
                    logger 4 "Installed"
                    for container in (list_menu $ctcontainer_root)
                        printf "$container "
                        sudo du -sh $ctcontainer_root/$container | awk '{ print $1 }'
                    end
                case '*'
                    logger 4 "Installed"
                    list_menu $ctcontainer_root
            end
        case available
            logger 4 "Available"
            read_lxc all_images
        case '*'
            logger 4 "Available"
            read_lxc all_images
            logger 4 "Installed"
            list_menu $ctcontainer_root
    end
end
