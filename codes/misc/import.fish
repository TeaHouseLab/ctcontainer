function import
    set container $argv[1]
    if [ "$container" = "" ]
        set_color red
        logger 4 "Nothing to import,abort"
        set_color normal
        exit
    end
    set containername (basename $container)
    if [ "$ctcontainer_log_level" = debug ]
        logger 2 "set rootfs.import.ctcontainer -> $container"
        logger 2 "set containername.import.ctcontainer -> $containername"
    end
    logger 0 "Importing..."
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
        logger 2 "set containername.import.ctcontainer -> $containername"
    end
    if test -d $containername
        logger 3 "Found a folder which has the same name of container to import,purge it?[y/n]"
        read -n1 -P "$prefix >>> " _purge_
        switch $_purge_
            case n N
                logger 4 "Abort."
                exit
            case y Y '*'
                sudo rm -rf $ctcontainer_root/$containername
        end
    end
    if sudo cp -r $container $containername
        sudo sh -c "echo 'safety:x:1000:1000:Linux User,,,:/home/safety:/bin/sh' >> $ctcontainer_root/$containername/etc/passwd"
        sudo sh -c "echo 'safety:x:1000:' >> $ctcontainer_root/$containername/etc/group"
        sudo sh -c "echo 'safety:!:18986:0:99999:7:::' >> $ctcontainer_root/$containername/etc/shadow"
        sudo sh -c "mkdir $ctcontainer_root/$containername/home/safety"
        set ctcontainer_safety_level 1
        set ctcontainer_auto_umount 1
        chroot_run $containername /bin/sh --login -c 'chown -R safety:safety /home/safety & chmod -R 755 /home/safety & passwd -u safety & echo "safety    ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers & echo "0d7882da60cc3838fabc4efc62908206" | tee /etc/machine-id' &>/dev/null
        cat /etc/resolv.conf | sudo tee "$ctcontainer_root/$containername/etc/resolv.conf" &>/dev/null
        logger 1 "$container deployed in $ctcontainer_root/$containername"
    else
        logger 4 "Cannot copy the rootfs to root.ctcontainer,checkout the debug info and try to import again"
    end
end
