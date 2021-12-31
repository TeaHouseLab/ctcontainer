function ctconfig_init
    set_color red
    echo "$prefix Detected First Launching,We need your password to create the config file"
    set_color normal
    sudo sh -c "echo "ctcontainer_root=/opt/ctcontainer" > /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "ctcontainer_share=$HOME/ctcontainer_share" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "log_level=info" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "backend=chroot" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "safety_level=-1" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "auto_umount=1" >> /etc/centerlinux/conf.d/ctcontainer.conf"
end
