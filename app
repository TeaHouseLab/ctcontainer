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

        run argv[2] argv[3]  >>> Run command in chroot
        argv[2]: the code of container
        argv[3]: the executable in chroot
          --ctlog_level={debug,info}
          --ctauto_umount={0,1}
          --ctsafety_level={0,1,2}
        init argv[2] (-f if you don't want the random container code) >>> Create a container
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
#!/usr/bin/env fish
function logger-warn
  set_color magenta
  echo "$prefix [Warn] $argv[1..-1]"
  set_color normal
end
function logger-error
  set_color red
  echo "$prefix [Error] $argv[1..-1]"
  set_color normal
end
function logger-info
  set_color normal
  echo "$prefix [Info] $argv[1..-1]"
  set_color normal
end
function logger-debug
  set_color yellow
  echo "$prefix [Debug] $argv[1..-1]"
  set_color normal
end
function logger-success
  set_color green
  echo "$prefix [Successed] $argv[1..-1]"
  set_color normal
end
function logger -d "a lib to print msg quickly"
switch $argv[1]
case 0
  logger-info $argv[2..-1]
case 1
  logger-success $argv[2..-1]
case 2
  logger-debug $argv[2..-1]
case 3
  logger-warn $argv[2..-1]
case 4
  logger-error $argv[2..-1]
end
end
function ctconfig_init
    set_color red
    echo "$prefix Detected First Launching,We need your password to create the config file"
    set_color normal
    sudo sh -c "echo "ctcontainer_root=/opt/ctcontainer" > /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "ctcontainer_share=$HOME/ctcontainer_share" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "log_level=info" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "backend=chroot" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "safety_level=1" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "auto_umount=1" >> /etc/centerlinux/conf.d/ctcontainer.conf"
end
function setup_user_share
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
    for container in $argv[1..-1]
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
end
function run
    set -lx container $argv[1]
    if test -d $ctcontainer_root/$container
    else
        logger 4 "No such container exist,abort,check your containerlist,or probably there's a incorrect option is providered"
        exit
    end
    if [ "$argv[2..-1]" = "" ]
        logger 4 "Nothing to run,abort"
        exit
    end
    logger 0 "Launching $container from $ctcontainer_root"
    setup_user_share
    if [ "$ctcontainer_safety_level" = 2 ]
    else
        setup_user_xorg
    end
    cd $ctcontainer_root
    if [ "$ctcontainer_safety_level" = 1 ]; or [ "$ctcontainer_safety_level" = 2 ]
        if [ "$ctcontainer_log_level" = debug ]
            logger 2 'mount in read-only filesystem'
        end
        if grep -qs "$ctcontainer_root/$container/dev" /proc/mounts
        else
            sudo mount -o bind,ro /dev $ctcontainer_root/$container/dev
        end
        if grep -qs "$ctcontainer_root/$container/dev/pts" /proc/mounts
        else
            sudo mount -o bind /dev/pts $ctcontainer_root/$container/dev/pts
        end
        if grep -qs "$ctcontainer_root/$container/proc" /proc/mounts
        else
            sudo mount -o bind,ro /proc $ctcontainer_root/$container/proc
        end
        if grep -qs "$ctcontainer_root/$container/sys" /proc/mounts
        else
            sudo mount -o bind,ro /sys $ctcontainer_root/$container/sys
        end
    else
        if [ "$ctcontainer_log_level" = debug ]
            logger 2 'mount in read-write filesystem'
        end
        if grep -qs "$ctcontainer_root/$container/dev" /proc/mounts
        else
            sudo mount -o bind,rw /dev $ctcontainer_root/$container/dev
        end
        if grep -qs "$ctcontainer_root/$container/dev/pts" /proc/mounts
        else
            sudo mount -o bind /dev/pts $ctcontainer_root/$container/dev/pts
        end
        if grep -qs "$ctcontainer_root/$container/proc" /proc/mounts
        else
            sudo mount -o bind,rw /proc $ctcontainer_root/$container/proc
        end
        if grep -qs "$ctcontainer_root/$container/sys" /proc/mounts
        else
            sudo mount -o bind,rw /sys $ctcontainer_root/$container/sys
        end
    end
    if [ "$ctcontainer_safety_level" = 2 ]
        sudo chroot --userspec safety:safety $container env HOME=/home/safety DISPLAY=:0 $argv[2..-1]
    else
        sudo chroot $container env DISPLAY=:0 $argv[2..-1]
    end
    if [ "$ctcontainer_auto_umount" = 1 ]
        sudo umount -f -l $ctcontainer_root/$container/dev
        sudo umount -f -l $ctcontainer_root/$container/proc
        sudo umount -f -l $ctcontainer_root/$container/sys
        if grep -qs "$ctcontainer_root/$container/tmp/.X11-unix" /proc/mounts
            sudo umount -f -l $ctcontainer_root/$container/tmp/.X11-unix
        end
        sudo umount -f -l $ctcontainer_root/$container/ctcontainer_share
        logger 0 Umountd
    else
        logger 3 "Do you want to umount bind mounts(if another same container is running,choose no)[y/n]"
        read -n1 -P "$prefix >>> " _umount_
        switch $_umount_
            case n N
                logger 0 "I'm not going to umount it,exit chroot only"
            case y Y '*'
                sudo umount -f -l $ctcontainer_root/$container/dev
                sudo umount -f -l $ctcontainer_root/$container/proc
                sudo umount -f -l $ctcontainer_root/$container/sys
                if grep -qs "$ctcontainer_root/$container/tmp/.X11-unix" /proc/mounts
                    sudo umount -f -l $ctcontainer_root/$container/tmp/.X11-unix
                end
                sudo umount -f -l $ctcontainer_root/$container/ctcontainer_share
                logger 0 Umountd
        end
    end
end
function setup_user_xorg
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
    if grep -qs "$ctcontainer_root/$container/tmp/.X11-unix" /proc/mounts
    else
        sudo mount -o bind /tmp/.X11-unix $ctcontainer_root/$container/tmp/.X11-unix
    end
end
function list
    echo ">Available<"
    curl -s -L https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/available
    echo
    echo ">Installed<"
    list_menu $ctcontainer_root
end
function init
    set container $argv[1]
    set containername $container
    if [ "$containername" = "" ]
        set_color red
        echo "$prefix [error] Nothing to init,abort"
        set_color normal
        exit
    end
    set_color yellow
    echo "$prefix Deploying..."
    set_color normal
    cd $ctcontainer_root
    if echo $argv[2] | grep -q -i '\-f'
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
    if sudo -E curl -s -L -o $container.tar.gz https://cdngit.ruzhtw.top/ctcontainer/$container.tar.gz
        set_color green
        echo "$prefix $container Package downloaded"
        set_color normal
        sudo mkdir -p $containername
        sudo mv $container.tar.gz $containername
        cd $containername
        if sudo tar xf $container.tar.gz
            sudo sh -c "echo 'safety:x:1000:1000:Linux User,,,:/home/safety:/bin/sh' >> $ctcontainer_root/$containername/etc/passwd"
            sudo sh -c "echo 'safety:x:1000:' >> $ctcontainer_root/$containername/etc/group"
            sudo sh -c "echo 'safety:!:18986:0:99999:7:::' >> $ctcontainer_root/$containername/etc/shadow"
            sudo sh -c "mkdir $ctcontainer_root/$containername/home/safety"
            run $containername sh -c 'chown -R safety:safety /home/safety && chmod -R 755 /home/safety'
            sudo sh -c "echo 'nameserver 8.8.8.8' > $ctcontainer_root/$containername/etc/resolv.conf"
            set_color green
            echo "$prefix $container deployed in $ctcontainer_root/$containername"
            set_color normal
        else
            sudo rm -rf $ctcontainer_root/$containername
            set_color red
            echo "$prefix [error] Check your network and the name of container(use ctcontainer list to see all available distros)"
            set_color normal
        end
    else
        set_color red
        echo "$prefix Failed,check your network connective"
        set_color normal
    end
end
echo Build_Time_UTC=2021-12-26_02:02:25
set -lx prefix [ctcontainer]
set -lx ctcontainer_root /opt/ctcontainer
set -lx ctcontainer_share $HOME/ctcontainer_share
set -lx ctcontainer_log_level info
set -lx ctcontainer_backend chroot
set -lx ctcontainer_safety_level 1
set -lx ctcontainer_auto_umount 1
if test -d /etc/centerlinux/conf.d/
else
    sudo mkdir -p /etc/centerlinux/conf.d/
end
if test -e /etc/centerlinux/conf.d/ctcontainer.conf
    set ctcontainer_root (sed -n '/ctcontainer_root=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/ctcontainer_root=//g')
    set ctcontainer_share (sed -n '/ctcontainer_share=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/ctcontainer_share=//g')
    set ctcontainer_log_level (sed -n '/log_level=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/log_level=//g')
    set ctcontainer_backend (sed -n '/backend=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/backend=//g')
    set ctcontainer_safety_level (sed -n '/safety_level=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/safety_level=//g')
    set ctcontainer_auto_umount (sed -n '/auto_umount=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/auto_umount=//g')
else
    ctconfig_init
end
if test -d $ctcontainer_root
else
    set_color red
    logger 4 "root.ctcontainer not found,try to create it under root"
    set_color normal
    sudo mkdir -p $ctcontainer_root
end
argparse -i -n $prefix ctlog_level= ctauto_umount= ctsafety_level= ctbackend= -- $argv
if set -q _flag_ctlog_level
    set ctcontainer_log_level $_flag_ctlog_level
end
if set -q _flag_ctauto_umount
    set ctcontainer_auto_umount $_flag_ctauto_umount
end
if set -q _flag_ctsafety_level
    set ctcontainer_safety_level $_flag_ctsafety_level
end
if set -q _flag_ctbackend
    set ctcontainer_backend $_flag_ctbackend
end
if [ "$ctcontainer_log_level" = debug ]
    logger 2 "set root.ctcontainer -> $ctcontainer_root"
    logger 2 "set share.ctcontainer -> $ctcontainer_share"
    logger 2 "set log_level.ctcontainer -> $ctcontainer_log_level"
    logger 2 "set backend.ctcontainer -> $ctcontainer_backend"
    logger 2 "set safety_level.ctcontainer -> $ctcontainer_safety_level"
    logger 2 "set auto_umount.ctcontainer -> $ctcontainer_auto_umount"
end
switch $argv[1]
    case purge
        purge $argv[2..-1]
    case init
        init $argv[2] $argv[3]
    case run
        run $argv[2] $argv[3..-1]
    case list
        list
    case v version
        set_color yellow
        echo "FrostFlower@build6"
        set_color normal
    case install
        install ctcontainer
    case uninstall
        uninstall ctcontainer
    case h help '*'
        help_echo
end
