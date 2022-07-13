function ctconfig_init
    set_color red
    echo "$prefix Detected First Launching,We need your password to create the config file"
    set_color normal
    echo "ctcontainer_root=/opt/ctcontainer 
ctcontainer_share=$HOME/ctcontainer_share 
log_level=info 
backend=chroot 
safety_level=-1 
auto_umount=1
x11=xhost
source=https://us.lxd.images.canonical.com" >/etc/centerlinux/conf.d/ctcontainer.conf
end
