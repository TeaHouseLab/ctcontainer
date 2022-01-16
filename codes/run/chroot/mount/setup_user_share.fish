function setup_user_share
    if test -d $ctcontainer_share
    else
        mkdir -p $ctcontainer_share
    end
    if test -d $ctcontainer_root/$container/ctcontainer_share
    else
        sudo mkdir -p $ctcontainer_root/$container/ctcontainer_share
    end
    if grep -qs "$ctcontainer_root/$container/ctcontainer_share" /proc/mounts
    else
    sudo mount -o bind $ctcontainer_share $ctcontainer_root/$container/ctcontainer_share
    end
end
