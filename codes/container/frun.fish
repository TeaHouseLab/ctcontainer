function frun
set container $argv[1]
if [ "$argv[2..-1]" = "" ]
  set_color red
  echo "$prefix [error] Nothing to run,abort"
  set_color normal
  exit
end
echo "$prefix [info] Launching $container from $ctcontainer_root"
setup_user_share $container
setup_user_xorg $container
cd $ctcontainer_root
if grep -qs "$ctcontainer_root/$container/dev" /proc/mounts
else
sudo mount -o bind /dev $ctcontainer_root/$container/dev
end
if grep -qs "$ctcontainer_root/$container/dev/pts" /proc/mounts
else
sudo mount -o bind /dev/pts $ctcontainer_root/$container/dev/pts
end
if grep -qs "$ctcontainer_root/$container/proc" /proc/mounts
else
sudo mount -o bind /proc $ctcontainer_root/$container/proc
end
if grep -qs "$ctcontainer_root/$container/sys" /proc/mounts
else
sudo mount -o bind /sys $ctcontainer_root/$container/sys
end
sudo chroot $container env DISPLAY=:0 $argv[2..-1]
set_color yellow
echo "$prefix [warn] Do you want to umount bind mounts(if another same container is running,choose no)[y/n]"
set_color normal
read -n1 -P "$prefix >>> " _umount_
  switch $_umount_
  case y Y
    sudo umount -f -l $ctcontainer_root/$container/dev
    sudo umount -f -l $ctcontainer_root/$container/proc
    sudo umount -f -l $ctcontainer_root/$container/sys
    sudo umount -f -l $ctcontainer_root/$container/tmp/.X11-unix
    sudo umount -f -l $ctcontainer_root/$container/ctcontainer_share
    set_color green
    echo "$prefix [info] Umountd"
    set_color normal
  case n N
    set_color green
    echo "$prefix [info] I'm not going to umount it,exit chroot only"
    set_color normal
  end
end
