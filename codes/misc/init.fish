function init
    set container $argv[1]
    set containername $container
    if [ "$ctcontainer_log_level" = debug ]
        logger 2 "set container.init.ctcontainer -> $container"
        logger 2 "set containername.init.ctcontainer -> $ctcontainername"
    end
    if [ "$containername" = "" ]
        logger 4 "Nothing to init,abort"
        exit
    end
    logger 1 "Deploying..."
    cd $ctcontainer_root
    if echo $argv[2] | grep -q -i '\-f'
        logger 0 "Using origin name mode,container might be killed(coverd)"
    else
        while test -d $containername$initraid
            logger 3 "The random container name has existed,generating a new one"
            set initraid (random 1000 1 9999)
            set containername $containername$initraid
        end
    end
    if [ "$ctcontainer_log_level" = debug ]
        logger 2 "set containername.import.ctcontainer -> $ctcontainername"
        logger 2 "curl.init.ctcontainer ==> Grabbing https://cdngit.ruzhtw.top/ctcontainer/$container"
    end
    if sudo -E curl --progress-bar -L -o $container.tar.gz https://cdngit.ruzhtw.top/ctcontainer/$container
        if file $container.tar.gz | grep -q 'compressed'
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
            chroot_run $containername /bin/sh -c 'chown -R safety:safety /home/safety & chmod -R 755 /home/safety & passwd -u safety & echo "safety    ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers & echo "0d7882da60cc3838fabc4efc62908206" | tee /etc/machine-id' &>/dev/null
            sudo cp -f --remove-destination /etc/resolv.conf "$ctcontainer_root/$containername/etc/resolv.conf"
            sudo rm $ctcontainer_root/$containername/$container.tar.gz
            logger 1 "$container deployed in $ctcontainer_root/$containername"
        else
            sudo rm -rf $ctcontainer_root/$containername/$container.tar.gz
            logger 4 "Check your network and the name of container(use ctcontainer list to see all available distros)"
        end
    else
        logger 4 "Failed to download rootfs,check your network connective"
    end
end
