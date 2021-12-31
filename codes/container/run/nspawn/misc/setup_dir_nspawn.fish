function setup_dir_nspawn
    if test -d $ctcontainer_root/$container/var/run/dbus
    else
        sudo mkdir -p $ctcontainer_root/$container/var/run/dbus
    end
    if test -d $ctcontainer_root/$container$XDG_RUNTIME_DIR
    else
        sudo mkdir -p $ctcontainer_root/$container$XDG_RUNTIME_DIR
    end
    if test -d $ctcontainer_root/$container/tmp/.X11-unix
    else
        sudo mkdir -p $ctcontainer_root/$container/tmp/.X11-unix
    end
    if test -d $ctcontainer_share
    else
        mkdir -p $ctcontainer_share
    end
    if test -d $ctcontainer_root/$container/ctcontainer_share
    else
        sudo mkdir -p $ctcontainer_root/$container/ctcontainer_share
    end
end
