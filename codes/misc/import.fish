function import
    set container $argv[1]
    if [ "$container" = "" ]
        logger 5 "Nothing to import,abort"
        exit
    end
    set containername (basename $container)
    if [ "$ctcontainer_log_level" = debug ]
        logger 3 "set rootfs.import.ctcontainer -> $container"
        logger 3 "set containername.import.ctcontainer -> $containername"
    end
    logger 0 "Importing..."
    cd $ctcontainer_root
    argparse -i -n $prefix f/forcename 'n/name=' -- $argv
    if set -q _flag_forcename
        logger 4 "Using forcename mode,container might be killed(coverd)"
    else
        while test -d $containername$initraid
            logger 4 "The container name has existed,generating a new one"
            set initraid (random 1000 1 9999)
            set containername $containername$initraid
        end
    end
    if set -q _flag_name
        logger 4 "Using custom name mode,container might be killed(coverd)"
        if test "$_flag_name" = ""
            logger 5 "You can`t create a container without a name, abort"
            exit
        else
            set containername $_flag_name
        end
    end
    if [ "$ctcontainer_log_level" = debug ]
        logger 3 "set containername.import.ctcontainer -> $containername"
    end
    if test -d $containername
        logger 3 "A container has already exist with this name, purge and overwrite it?[y/n]"
        read -n1 -P "$prefix >>> " _purge_
        switch $_purge_
            case n N
                logger 1 Abort
                exit
            case y Y '*'
                sudo rm -rf $ctcontainer_root/$containername
        end
    end
    if sudo cp -r $container $containername
        sudo sh -c "echo 'safety:x:1000:1000:Linux User,,,:/home/safety:/bin/sh' >> $ctcontainer_root/$containername/etc/passwd & echo 'safety:x:1000:' >> $ctcontainer_root/$containername/etc/group & echo 'safety:!:18986:0:99999:7:::' >> $ctcontainer_root/$containername/etc/shadow & mkdir $ctcontainer_root/$containername/home/safety & rm $ctcontainer_root/$containername/etc/hostname & echo $containername > $ctcontainer_root/$containername/etc/hostname & echo 127.0.0.1  $containername >> $ctcontainer_root/$containername/etc/hosts"
        sudo cp -f --remove-destination /etc/resolv.conf "$ctcontainer_root/$containername/etc/resolv.conf"
        set ctcontainer_safety_level 1
        set ctcontainer_auto_umount 1
        chroot_run $containername /bin/sh -c 'chown -R safety:safety /home/safety & chmod -R 755 /home/safety & passwd -u safety & echo "safety    ALL=(ALL:ALL) ALL" >> tee -a /etc/sudoers & echo "0d7882da60cc3838fabc4efc62908206" > /etc/machine-id' &>/dev/null
        logger 2 "$container deployed in $ctcontainer_root/$containername"
    else
        logger 5 "Cannot copy the rootfs to root.ctcontainer,checkout the debug info and try to import again"
    end
end
