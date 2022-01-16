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
            set ctcontainer_safety_level 1
            set ctcontainer_auto_umount 1
            chroot_run $containername sh -c 'chown -R safety:safety /home/safety && chmod -R 755 /home/safety'
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
