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
echo "$prefix Launching..."
set container $argv[1]
set program $argv[2]
cd /opt/ctcontainer/
sudo mount --bind /dev /opt/ctcontainer/$container/dev
sudo mount --bind /proc /opt/ctcontainer/$container/proc
sudo mount --bind /sys /opt/ctcontainer/$container/sys
sudo chroot $container $program
sudo umount --recursive /opt/ctcontainer/$container/dev
sudo umount --recursive /opt/ctcontainer/$container/proc
sudo umount --recursive /opt/ctcontainer/$container/sys
end
function init
set container $argv[1]
set_color yellow
echo "$prefix Deploying..."
cd /opt
if sudo -E curl -s -L -o $container.tar.gz https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/$container.tar.gz
  sudo mkdir -p ctcontainer/$container
  sudo mv $container.tar.gz ctcontainer/$container
  cd ctcontainer/$container
  sudo tar xf $container.tar.gz
  sudo sh -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
  set_color green
  echo "$prefix $container deployed in /opt/ctcontainer/$container"
  set_color normal
else
  set_color red
  echo "$prefix Failed,check your network connective"
  set_color normal
end
end
echo Build_Time_UTC=2021-12-12_06:55:50
set prefix [ctcontainer]
switch $argv[1]
case purge
  purge $argv[1]
case init
  init $argv[2]
case run
  run $argv[2] $argv[3]
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
