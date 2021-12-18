#!/usr/bin/env fish
function checkdependence
  if test -e $argv
    echo -e "\033[32m[checkdependence]check passed - $argv exist\033[0m"
  else
    echo -e "\033[0;31m[checkdependence]check failed - plz install $argv\033[0m"
    exit
  end
end
function checknetwork
  if curl -s -L $argv[1] | grep -q $argv[2]
    echo -e "\033[32m[checknetwork]check passed - u`ve connected to $argv[1]\033[0m"
  else
    echo -e "\033[0;31m[checknetwork]check failed - check your network connection\033[0m"
  end
end
function dir_exist
  if test -d $argv[1]
    echo -e "\033[32m[checkdir]check passed - dir $argv[1] exist\033[0m"
  else
    echo -e "\033[0;31m[checkdir]check failed - dir $argv[1] doesn't exist,going to makr one\033[0m"
    mkdir $argv[1]
  end
end
function list_menu
ls $argv | sed '\~//~d'
end
function help_echo
  echo "==========Help Documentation=========="
  set_color green
  echo "(./)app argv[1]"
  set_color normal
  echo " -argv[1]:the command to execute"
  echo "  -Available:
        list >>> list installed container
        
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
cd $ctcontainer_root
  if test -d $container
    if sudo rm -rf $container
      set_color green
      echo "$prefix Purged $container"
      set_color normal
    else
      set_color red
      echo "$prefix Ouch!Something went wrong at {ctcontainer.purge.rm}"
      set_color normal
    end
  else
    set_color red
    echo "$prefix [error]No such container in root.ctcontainer"
    set_color normal
  end
end
function run
set container $argv[1]
echo "$prefix [info] Launching $container from $ctcontainer_root"
setup_user_share $container
setup_user_xorg $container
cd $ctcontainer_root
sudo mount -o bind,ro /dev $ctcontainer_root/$container/dev
sudo mount -o bind,ro /proc $ctcontainer_root/$container/proc
sudo mount -o bind,ro /sys $ctcontainer_root/$container/sys
sudo mount -o bind /dev/pts $ctcontainer_root/$container/dev/pts
sudo chroot $container env DISPLAY=:0 $argv[2..-1]
sudo umount --recursive -f -l $ctcontainer_root/$container/dev
sudo umount --recursive -f -l $ctcontainer_root/$container/proc
sudo umount --recursive -f -l $ctcontainer_root/$container/sys
sudo umount --recursive -f -l $ctcontainer_root/$container/tmp/.X11-unix
sudo umount --recursive -f -l $ctcontainer_root/$container/ctcontainer_share
end
function setup_user_xorg
set container $argv[1]
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
sudo mount -o bind /tmp/.X11-unix $ctcontainer_root/$container/tmp/.X11-unix
end
function list
curl -s -L https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/available
echo
echo "Installed"
list_menu $ctcontainer_root
end
function init
set container $argv[1]
set containername $container
set_color yellow
echo "$prefix Deploying..."
set_color normal
cd $ctcontainer_root
if echo $argv[2..-1] | grep -q -i '\-f'
  set_color cyan
  echo "$prefix [Info] Using origin name mode,container might be killed(coverd)"
  set_color normal
else
  while test -d $container$initraid
  set_color yellow
  echo "$prefix [info] The random container name has existed,generating a new one"
  set_color normal
  set initraid (random 1000 1 9999)
  set containername $container$initraid
  end
end
if sudo -E curl -s -L -o $container.tar.gz https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/$container.tar.gz
  set_color green
  echo "$prefix $container Package downloaded"
  set_color normal
  sudo mkdir -p $containername
  sudo mv $container.tar.gz $containername
  cd $containername
  sudo tar xf $container.tar.gz
  sudo sh -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
  set_color green
  echo "$prefix $container deployed in $ctcontainer_root/$containername"
  set_color normal
else
  set_color red
  echo "$prefix Failed,check your network connective"
  set_color normal
end
end
echo Build_Time_UTC=2021-12-18_05:27:00
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
  purge $argv[2]
case init
  init $argv[2] $argv[3..-1]
case run
  run $argv[2] $argv[3..-1]
case list
  list
case v version
  set_color yellow
  echo "FrostFlower@build1"
  set_color normal
case install
  install ctcontainer
case uninstall
  uninstall ctcontainer
case h help '*'
  help_echo
end
