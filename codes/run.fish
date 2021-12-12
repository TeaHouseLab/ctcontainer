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
