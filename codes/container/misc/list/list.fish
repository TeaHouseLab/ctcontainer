function list
    switch $argv[1]
        case installed
            switch $argv[2]
                case size
                    echo ">Installed<"
                    for container in (list_menu $ctcontainer_root)
                        printf "$container "
                        sudo du -sh $ctcontainer_root/$container | awk '{ print $1 }'
                    end
                case '*'
                    echo ">Installed<"
                    list_menu $ctcontainer_root
            end
        case available
            echo ">Available<"
            curl -s -L https://cdngit.ruzhtw.top/ctcontainer/available
        case '*'
            echo ">Available<"
            curl -s -L https://cdngit.ruzhtw.top/ctcontainer/available
            echo
            echo ">Installed<"
            list_menu $ctcontainer_root
    end
end
