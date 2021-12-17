#!/usr/bin/env fish
function help_echo
  echo "==========Help Documentation=========="
  set_color green
  echo "(./)app argv[1]"
  set_color normal
  echo " -argv[1]:the command to execute"
  echo "  -Available:

        run argv[2] argv[3] >>> Run command in chroot
        argv[2]: the code of container
        argv[3]: the executable in chroot

        init argv[2] >>> Create a container
        argv[2]: debian,debian-testing,debian-unstable,alpinelinux

        purge argv[2] >>> Destroy a container
        argv[2]: debian,debian-testing,debian-unstable,alpinelinux"
  echo "======================================"
end
function install
set installname $argv[1]
  set dir (realpath (dirname (status -f)))
  set filename (status --current-filename)
  chmod +x $dir/$filename
  sudo cp $dir/$filename /usr/bin/$installname
  set_color green
  echo "$prefix Installed"
  set_color normal
end
function uninstall
set installname $argv[1]
  sudo rm /usr/bin/$installname
  set_color green
  echo "$prefix Removed"
  set_color normal
end
function ctconfig_init
set_color red
echo "$prefix Detected First Launching,We need your password to create the config file"
set_color normal
sudo sh -c "echo "ctcontainer_root=/opt/ctcontainer/" > /etc/centerlinux/conf.d/ctcontainer.conf"
sudo sh -c "echo "ctcontainer_share=$HOME/ctcontainer_share" >> /etc/centerlinux/conf.d/ctcontainer.conf"
end
function setup_user_share
set container $argv[1]
if test -d $ctcontainer_share
else
  mkdir -p $ctcontainer_share
end
if test -d $ctcontainer_root/$container/ctcontainer_share
else
  sudo mkdir -p $ctcontainer_root/$container/ctcontainer_share
end
set_color cyan
set_color normal
sudo mount --bind $ctcontainer_share $ctcontainer_root/$container/ctcontainer_share
end
function purge
set container $argv[1]
cd /opt/ctcontainer/
if sudo rm -rf $container
  set_color green
  echo "$prefix Purged $container"
  set_color normal
else
  set_color red
  echo "$prefix Ouch!Something went wrong at {ctcontainer.purge.rm}"
  set_color normal
end
end
function run
set container $argv[1]
echo "$prefix [info] Launching $container from $ctcontainer_root"
setup_user_share $container
cd $ctcontainer_root
sudo mount --bind -o ro /dev $ctcontainer_root/$container/dev
sudo mount --bind -o ro /proc $ctcontainer_root/$container/proc
sudo mount --bind -o ro /sys $ctcontainer_root/$container/sys
sudo mount --bind -o ro /dev/pts $ctcontainer_root/$container/dev/pts
sudo chroot $container $argv[2..-1]
sudo umount --recursive $ctcontainer_root/$container/dev
sudo umount --recursive $ctcontainer_root/$container/proc
sudo umount --recursive $ctcontainer_root/$container/sys
sudo umount --recursive $ctcontainer_root/$container/ctcontainer_share
end
function init
set container $argv[1]
set_color yellow
echo "$prefix Deploying..."
cd $ctcontainer_root
if sudo -E curl -s -L -o $container.tar.gz https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/$container.tar.gz
  sudo mkdir -p $container
  sudo mv $container.tar.gz $container
  cd $container
  sudo tar xf $container.tar.gz
  sudo sh -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
  set_color green
  echo "$prefix $container deployed in $ctcontainer_root/$container"
  set_color normal
else
  set_color red
  echo "$prefix Failed,check your network connective"
  set_color normal
end
end
echo Build_Time_UTC=2021-12-17_15:52:41
set prefix [ctcontainer]
if test -d /etc/centerlinux/conf.d/
else
  sudo mkdir -p /etc/centerlinux/conf.d/
end
if test -e /etc/centerlinux/conf.d/ctcontainer.conf
  set ctcontainer_root (sed -n '/ctcontainer_root=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/ctcontainer_root=//g')
  set ctcontainer_share (sed -n '/ctcontainer_share=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/ctcontainer_share=//g')
  set_color yellow
  echo "$prefix [debug] set root.ctcontainer -> $ctcontainer_root"
  echo "$prefix [debug] set share.ctcontainer -> $ctcontainer_share"
  set_color normal
else
  ctconfig_init
end
switch $argv[1]
case purge
  purge $argv[1]
case init
  init $argv[2]
case run
  run $argv[2] $argv[3..-1]
case v version
  set_color yellow
  echo "FrostFlower@build0"
  set_color normal
case install
  install ctcontainer
case uninstall
  uninstall ctcontainer
case h help '*'
  help_echo
end
