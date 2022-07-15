function init
    set container $argv[1]
    set containername $container
    if [ "$ctcontainer_log_level" = debug ]
        logger 3 "set container.init.ctcontainer -> $container"
        logger 3 "set containername.init.ctcontainer -> $ctcontainername"
    end
    if [ "$containername" = "" ]
        logger 5 "Nothing to init,abort"
        exit
    end
    logger 0 "Deploying..."
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
            logger 5 "You can't create a container without a name, abort"
            exit
        else
            set containername $_flag_name
        end
    end
    set remote_path (read_lxc get_path $container)
    if [ "$ctcontainer_log_level" = debug ]
        logger 3 "set containername.import.ctcontainer -> $ctcontainername"
        logger 3 "curl.init.ctcontainer ==> Grabbing $ctcontainer_source/$remote_path"
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
    if sudo -E curl --progress-bar -L -o $container.tar.gz $ctcontainer_source/$remote_path
        if file $container.tar.gz | grep -q compressed
            logger 2 "$container Package downloaded"
        else
            logger 5 "This is not a tarball,abort"
            sudo rm -- $container.tar.gz
            exit
        end
        sudo mkdir -p $containername
        sudo mv $container.tar.gz $containername
        cd $containername
        if sudo tar --force-local -xf $container.tar.gz
            sudo sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $ctcontainer_root/$containername/etc/passwd & echo 'safety:x:1000:' >> $ctcontainer_root/$containername/etc/group & echo 'safety:!:18986:0:99999:7:::' >> $ctcontainer_root/$containername/etc/shadow & mkdir -p $ctcontainer_root/$containername/home/safety & rm $ctcontainer_root/$containername/etc/hostname & echo $containername > $ctcontainer_root/$containername/etc/hostname & echo 127.0.0.1  $containername >> $ctcontainer_root/$containername/etc/hosts"
            sudo cp -f --remove-destination /etc/resolv.conf "$ctcontainer_root/$containername/etc/resolv.conf"
            set ctcontainer_safety_level 0
            set ctcontainer_auto_umount 1
            chroot_run $containername /bin/sh -c 'chown -R safety:safety /home/safety & chmod -R 755 /home/safety & echo "safety    ALL=(ALL:ALL) ALL" >> tee -a /etc/sudoers & echo "0d7882da60cc3838fabc4efc62908206" > /etc/machine-id' &>/dev/null
            sudo rm $ctcontainer_root/$containername/$container.tar.gz
            logger 2 "$container deployed in $ctcontainer_root/$containername, remember to change the password of root and safety account(run with -p0 and -bchroot flag to enter chroot with root account and zero restriction)"
        else
            sudo rm -rf $ctcontainer_root/$containername
            logger 5 "Check your network and the name of container(use ctcontainer list to see all available distros)"
        end
    else
        sudo rm -- $container.tar.gz
        logger 5 "Failed to download rootfs,check your network connective"
    end
end
