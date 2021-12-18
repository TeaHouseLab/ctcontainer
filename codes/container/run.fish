function run
set container $argv[1]
echo "$prefix [info] Launching $container from $ctcontainer_root"
setup_user_share $container
cd $ctcontainer_root
sudo mount -o bind,ro /dev $ctcontainer_root/$container/dev
sudo mount -o bind,ro /proc $ctcontainer_root/$container/proc
sudo mount -o bind,ro /sys $ctcontainer_root/$container/sys
sudo mount -o bind /dev/pts $ctcontainer_root/$container/dev/pts
sudo chroot $container $argv[2..-1]
sudo umount --recursive $ctcontainer_root/$container/dev
sudo umount --recursive $ctcontainer_root/$container/proc
sudo umount --recursive $ctcontainer_root/$container/sys
sudo umount --recursive $ctcontainer_root/$container/ctcontainer_share
end
