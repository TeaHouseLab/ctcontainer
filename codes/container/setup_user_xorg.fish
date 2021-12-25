function setup_user_xorg
    if test -d $ctcontainer_root/$container/tmp/.X11-unix
    else
        sudo mkdir -p $ctcontainer_root/$container/tmp/.X11-unix
    end
    if command -q -v xhost
        xhost +local:
    else
        set_color red
        echo "$prefix [error] Xhost not found,xorg in container couldn't be set up,still try to mount the .X11-unix directory"
        set_color normal
    end
    if grep -qs "$ctcontainer_root/$container/tmp/.X11-unix" /proc/mounts
    else
        sudo mount -o bind /tmp/.X11-unix $ctcontainer_root/$container/tmp/.X11-unix
    end
end
