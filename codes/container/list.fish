function list
    echo ">Available<"
    curl -s -L https://cdngit.ruzhtw.top/ctcontainer/available
    echo
    echo ">Installed<"
    list_menu $ctcontainer_root
end
