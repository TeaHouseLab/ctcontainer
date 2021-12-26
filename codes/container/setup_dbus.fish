function setup_dbus
    if test -d $ctcontainer_root/$container/var/run/dbus
    else
        sudo mkdir -p $ctcontainer_root/$container/var/run/dbus
    end
    if test -d $ctcontainer_root/$container$XDG_RUNTIME_DIR
    else
        sudo mkdir -p $ctcontainer_root/$container$XDG_RUNTIME_DIR
    end
    if grep -qs "$ctcontainer_root/$container/var/run/dbus" /proc/mounts
    else
        sudo mount -o bind /var/run/dbus $ctcontainer_root/$container/var/run/dbus
    end
    if grep -qs "$ctcontainer_root/$container$XDG_RUNTIME_DIR" /proc/mounts
    else
        sudo mount -o bind $XDG_RUNTIME_DIR $ctcontainer_root/$container$XDG_RUNTIME_DIR
    end
end
