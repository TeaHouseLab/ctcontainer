function setup_user_pulseaudio
    if grep -qs "$ctcontainer_root/$container/var/lib/dbus" /proc/mounts
        mount -o bind /var/lib/dbus $ctcontainer_root/$container/var/lib/dbus
    end
end
