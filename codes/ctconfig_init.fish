function ctconfig_init
set_color red
echo "$prefix Detected First Launching,We need your password to create the config file"
set_color normal
sudo sh -c "echo "ctcontainer_root=/opt/ctcontainer/" > /etc/centerlinux/conf.d/ctcontainer.conf"
sudo sh -c "echo "ctcontainer_share=$HOME/ctcontainer_share" >> /etc/centerlinux/conf.d/ctcontainer.conf"
end
