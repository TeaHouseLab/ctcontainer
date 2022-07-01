function service
    argparse -i -n $prefix k/remove -- $argv
    set containers $argv[1]
    if set -q _flag_remove
        for container in $containers
            if [ "$container" = "" ]
                logger 5 "Nothing selected , abort"
                exit 1
            else
                if test -d $ctcontainer_root/$container; and test -r $ctcontainer_root/$container
                else
                    logger 5 "Container $container does not exist,abort,check your containerlist,or probably there's a incorrect option is provided"
                    exit 1
                end
            end
            if sudo rm /etc/systemd/system/ctcontainer-$container.service
                logger 2 "Systemd service for $container has been removed"
            else
                logger 5 "Something went wrong while removing systemd service for $container"
            end
        end
    else
        for container in $containers
            if [ "$container" = "" ]
                logger 5 "Nothing selected , abort"
                exit 1
            else
                if test -d $ctcontainer_root/$container; and test -r $ctcontainer_root/$container
                else
                    logger 5 "Container $container does not exist,abort,check your containerlist,or probably there's a incorrect option is provided"
                    exit 1
                end
            end
            echo "[Unit]
Description=ctcontainer-nspawn-$container
After=network.target
StartLimitIntervalSec=15
[Service]
User=root
ExecStart=ctcontainer -b nspawn -p 0 run $container whatever
SyslogIdentifier=ctcontainer-nspawn-$container
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/ctcontainer-$container.service &>/dev/null
            logger 2 "Systemd service for $container has been created at /etc/systemd/system/ctcontainer-$container.service"
        end
    end
end
