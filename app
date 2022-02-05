#!/usr/bin/env fish

function checkdependence
set 34ylli8_deps_ok 1
for 34ylli8_deps in $argv
    if command -q -v $34ylli8_deps
    else
        set 34ylli8_deps_ok 0
        if test -z "$34ylli8_dep_lost"
            set 34ylli8_deps_lost "$34ylli8_deps $34ylli8_deps_lost"
        else
            set 34ylli8_deps_lost "$34ylli8_deps"
        end
    end
end
if test "$34ylli8_deps_ok" -eq 0
    set_color red
    echo "$prefix [error] "Please install "$34ylli8_deps_lost"to run this program""
    set_color normal
    exit
end
end
function checknetwork
  if curl -s -L $argv[1] | grep -q $argv[2]
  else
    set_color red
    echo "$prefix [error] [checknetwork] check failed - check your network connection"
    set_color normal
  end
end
function dir_exist
  if test -d $argv[1]
  else
    set_color red
    echo "$prefix [error] [checkdir] check failed - dir $argv[1] doesn't exist,going to makr one"
    set_color normal
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
        list argv[2] argv[3] >>> list installed and Available container
          argv[2]:installed: list deployed container
                    argv[3]: size: count size of each container using du
                  available: list available container in online repo

        load argv[2] argv[3] >>> Run command in chroot,but you can run custom rootfs
          argv[2]: the path of rootfs(like /opt/debian or debian/)
          argv[3]: the executable in chroot
            -r/--ctroot=
            -s/--ctshare=
            -l/--ctlog_level={debug,info}
            -u/--ctauto_umount={0,1}
            -p/--ctsafety_level={0,1,2}
            -b/--ctbackend={chroot,nspawn}

        run argv[2] argv[3]  >>> Run command in chroot
          argv[2]: the code of container(use (./)ctcontainer list installed to know what you have installed)
          argv[3]: the executable in chroot
            -r/--ctroot=
            -s/--ctshare=
            -l/--ctlog_level={debug,info}
            -u/--ctauto_umount={0,1}
            -p/--ctsafety_level={0,1,2}
            -b/--ctbackend={chroot,nspawn}

        init argv[2] (-f if you don't want the random container code) >>> Create a container
          argv[2]: use (./)ctcontainer list available to know what you can grab from online repo

        purge argv[2] >>> Destroy a container
          argv[2]: use (./)ctcontainer list installed to know what you have installed
        
        v version >>> Show version"
  echo "======================================"
end

function install
set installname $argv[1]
  set dir (pwd)
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
  echo "$prefix [Succeeded] $argv[1..-1]"
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

function ctconfig_init
    set_color red
    echo "$prefix Detected First Launching,We need your password to create the config file"
    set_color normal
    sudo sh -c "echo "ctcontainer_root=/opt/ctcontainer" > /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "ctcontainer_share=$HOME/ctcontainer_share" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "log_level=info" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "backend=chroot" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "safety_level=-1" >> /etc/centerlinux/conf.d/ctcontainer.conf"
    sudo sh -c "echo "auto_umount=1" >> /etc/centerlinux/conf.d/ctcontainer.conf"
end
function list
    switch $argv[1]
        case installed
            switch $argv[2]
                case size
                    echo ">Installed<"
                    for container in (list_menu $ctcontainer_root)
                        printf "$container "
                        sudo du -sh $ctcontainer_root/$container | awk '{ print $1 }'
                    end
                case '*'
                    echo ">Installed<"
                    list_menu $ctcontainer_root
            end
        case available
            echo ">Available<"
            curl -s -L https://cdngit.ruzhtw.top/ctcontainer/available
        case '*'
            echo ">Available<"
            curl -s -L https://cdngit.ruzhtw.top/ctcontainer/available
            echo
            echo ">Installed<"
            list_menu $ctcontainer_root
    end
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
    if sudo -E curl --progress-bar -L -o $container.tar.gz https://cdngit.ruzhtw.top/ctcontainer/$container.tar.gz
        if file $container.tar.gz | grep -q 'gzip compressed'
            logger 1 "$container Package downloaded"
        else
            logger 4 "This is not a tarball,abort"
            sudo rm -- $container.tar.gz
            exit
        end
        sudo mkdir -p $containername
        sudo mv $container.tar.gz $containername
        cd $containername
        if sudo tar xf $container.tar.gz
            sudo sh -c "echo 'safety:x:1000:1000:Linux User,,,:/home/safety:/bin/sh' >> $ctcontainer_root/$containername/etc/passwd"
            sudo sh -c "echo 'safety:x:1000:' >> $ctcontainer_root/$containername/etc/group"
            sudo sh -c "echo 'safety:!:18986:0:99999:7:::' >> $ctcontainer_root/$containername/etc/shadow"
            sudo sh -c "mkdir $ctcontainer_root/$containername/home/safety"
            set ctcontainer_safety_level 1
            set ctcontainer_auto_umount 1
            chroot_run $containername sh -c 'chown -R safety:safety /home/safety && chmod -R 755 /home/safety && passwd -u safety && echo "safety    ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers' &>/dev/null
            cat /etc/resolv.conf | sudo tee "$ctcontainer_root/$containername/etc/resolv.conf" &>/dev/null
            sudo rm $ctcontainer_root/$containername/$container.tar.gz
            logger 1 "$container deployed in $ctcontainer_root/$containername"
        else
            sudo rm -rf $ctcontainer_root/$containername/$container.tar.gz
            logger 4 "Check your network and the name of container(use ctcontainer list to see all available distros)"
        end
    else
        set_color red
        echo "$prefix Failed,check your network connective"
        set_color normal
    end
end

function setup_dir_nspawn
    if test -d $ctcontainer_root/$container/var/run/dbus
    else
        sudo mkdir -p $ctcontainer_root/$container/var/run/dbus
    end
    if test -d $ctcontainer_root/$container$XDG_RUNTIME_DIR
    else
        sudo mkdir -p $ctcontainer_root/$container$XDG_RUNTIME_DIR
    end
    if test -d $ctcontainer_root/$container/tmp/.X11-unix
    else
        sudo mkdir -p $ctcontainer_root/$container/tmp/.X11-unix
    end
    if test -d $ctcontainer_share
    else
        mkdir -p $ctcontainer_share
    end
    if test -d $ctcontainer_root/$container/ctcontainer_share
    else
        sudo mkdir -p $ctcontainer_root/$container/ctcontainer_share
    end
end

function nspawn_run
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
    setup_dir_nspawn
    cd $ctcontainer_root
    essential_mount
    switch $ctcontainer_safety_level
        case -1
            sudo systemd-nspawn -q -u safety -D $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/home/safety USER=safety $argv[2..-1]
        case 0
            sudo systemd-nspawn -b -q -D $container
        case 1
            sudo systemd-nspawn -q -D $container env DISPLAY=:0 $argv[2..-1]
        case 2
            sudo systemd-nspawn -q -u safety -D $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/home/safety USER=safety $argv[2..-1]
        case h '*'
            logger 4 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
    essential_umount
end

function chroot_run
    set -lx container $argv[1]
    set -lx chroot_mount_point
    if [ "$ctload" = "true" ]
        cd (dirname $argv[1])
        set ctcontainer_root .
        set container (basename $argv[1])
    end
    if test -d $ctcontainer_root/$container
    else
        logger 4 "Container $container does not exist,abort,check your containerlist,or probably there's a incorrect option is provided"
        exit
    end
    if [ "$argv[2..-1]" = "" ]
        logger 4 "Nothing to run,abort"
        exit
    end
    cd $ctcontainer_root
    essential_mount
    switch $ctcontainer_safety_level
        case -1
            sudo chroot --userspec safety:safety $container env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/home/safety USER=safety $argv[2..-1]
        case 0
            sudo chroot $container env DISPLAY=:0 XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR $argv[2..-1]
        case 1
            sudo chroot $container env DISPLAY=:0 $argv[2..-1]
        case 2
            sudo chroot --userspec safety:safety $container env HOME=/home/safety USER=safety $argv[2..-1]
        case h '*'
            logger 4 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
    essential_umount
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
    if grep -qs "$ctcontainer_root/$container/ctcontainer_share" /proc/mounts
    else
    sudo mount -o bind $ctcontainer_share $ctcontainer_root/$container/ctcontainer_share
    end
end

function essential_mount
    logger 0 "Launching $container from $ctcontainer_root"
    function chroot_mount_ro
        for chroot_mount_target in $chroot_mount_point
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "Mounting $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target"
            end
            if grep -qs "$ctcontainer_root/$container$chroot_mount_target" /proc/mounts
            else
                sudo mount -o bind,ro $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target
            end
        end
    end
    function chroot_mount_rw
        for chroot_mount_target in $chroot_mount_point
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "Mounting $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target"
            end
            if grep -qs "$ctcontainer_root/$container$chroot_mount_target" /proc/mounts
            else
                sudo mount -o bind,rw $chroot_mount_target $ctcontainer_root/$container$chroot_mount_target
            end
        end
    end
    setup_user_share
    switch $ctcontainer_safety_level
        case 0 -1
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 'mount in read-write filesystem'
            end
            setup_user_xorg
            setup_dbus
            set chroot_mount_point /dev /dev/pts /proc /sys
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "set mount_point.essential_mount.run_chroot -> $chroot_mount_point"
            end
            chroot_mount_rw
        case 1 2
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 'mount in read-only filesystem'
            end
            setup_user_xorg
            set chroot_mount_point /dev /dev/pts /proc /sys
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "set mount_point.essential_mount.run_chroot -> $chroot_mount_point"
            end
            chroot_mount_ro
        case h '*'
            logger 4 "can't understand what is $ctcontainer_safety_level,abort"
            exit
    end
end

function setup_user_xorg
    if command -q -v xhost
        if xhost +local: &>/dev/null
        else
            if [ "$ctcontainer_log_level" = debug ]
                logger 2 "Xhost cannot be launched,skip"
            end
        end
    else
        if [ "$ctcontainer_log_level" = debug ]
            logger 2 "$prefix [error] Xhost not found,xorg in container couldn't be set up"
        end
    end
end

function essential_umount
    function chroot_umount
        set chroot_mount_point /dev/pts /dev /proc /sys /var/run/dbus /run/dbus "$XDG_RUNTIME_DIR" /ctcontainer_share
        for chroot_umount_target in $chroot_mount_point
            if grep -qs "$ctcontainer_root/$container$chroot_umount_target" /proc/mounts
                sudo umount -l $ctcontainer_root/$container$chroot_umount_target
            end
        end
        if grep -qs /dev/pts /proc/mounts
        else
            sudo mount devpts /dev/pts -t devpts
        end
        logger 1 Umountd
    end
    switch $ctcontainer_auto_umount
        case 0
            logger 3 "Do you want to umount bind mounts(if another same container is running,choose no)[y/n]"
            read -n1 -P "$prefix >>> " _umount_
            switch $_umount_
                case n N
                    logger 0 "I'm not going to umount it,exit chroot only"
                case y Y '*'
                    chroot_umount
            end
        case 1 '*'
            chroot_umount
    end
end

function setup_dbus
    if test -d $ctcontainer_root/$container/var/run/dbus
    else
        sudo mkdir -p $ctcontainer_root/$container/var/run/dbus
    end
    if test -d $ctcontainer_root/$container$XDG_RUNTIME_DIR
    else
        sudo mkdir -p $ctcontainer_root/$container$XDG_RUNTIME_DIR
    end
    if grep -qs "$ctcontainer_root/$container/var/run/dbus" /proc/mounts
    else
        sudo mount -o bind /var/run/dbus $ctcontainer_root/$container/var/run/dbus
    end
    if grep -qs "$ctcontainer_root/$container$XDG_RUNTIME_DIR" /proc/mounts
    else
        sudo mount -o bind $XDG_RUNTIME_DIR $ctcontainer_root/$container$XDG_RUNTIME_DIR
    end
end

echo Build_Time_UTC=2022-02-05_05:57:46
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
argparse -i -n $prefix 'r/ctroot=' 's/ctshare=' 'l/ctlog_level=' 'u/ctauto_umount=' 'p/ctsafety_level=' 'b/ctbackend=' -- $argv
if set -q _flag_ctroot
    set ctcontainer_root $_flag_ctroot
end
if set -q _flag_ctshare
    set ctcontainer_share $_flag_ctshare
end
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
        switch $ctcontainer_backend
            case chroot
                chroot_run $argv[2] $argv[3..-1]
            case nspawn
                nspawn_run $argv[2] $argv[3..-1]
        end
    case load
        set ctload true
        chroot_run $argv[2] $argv[3..-1]
    case list
        list $argv[2..-1]
    case v version
        logger 0 "Begonia@build2"
    case install
        install ctcontainer
    case uninstall
        uninstall ctcontainer
    case h help '*'
        help_echo
end
