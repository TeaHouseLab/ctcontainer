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
