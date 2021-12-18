function run
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
