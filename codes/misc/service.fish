function service
    set containers $argv[2..-1]
    switch $argv[1]
        case remove
            for container in $containers
                container_tester $container
                if sudo rm /etc/systemd/system/ctcontainer-$container.service
                    logger 2 "Systemd service for $container has been removed"
                else
                    logger 5 "Something went wrong while removing systemd service for $container"
                end
            end
        case create
            for container in $containers
                container_tester $container
                if test -e /etc/systemd/system/ctcontainer-$container.service
                    logger 3 "A service file had already been created for this container,remove it?[y/n]"
                    read -n1 -P "$prefix >>> " _remove_
                    switch $_remove_
                        case n N
                            logger 1 Abort
                            exit
                        case y Y '*'
                            sudo rm /etc/systemd/system/ctcontainer-$container.service
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
        case enable
            for container in $containers
                container_tester $container
                if sudo systemctl enable ctcontainer-$container; and sudo systemctl start ctcontainer-$container
                    logger 2 "Container $container is active and enabled on system startup"
                else
                    logger 5 "Something went wrong while enabling container $container"
                end
            end
        case disable
            for container in $containers
                container_tester $container
                if sudo systemctl disable ctcontainer-$container; and sudo systemctl stop ctcontainer-$container
                    logger 2 "Container $container stopped and disabled on system startup"
                else
                    logger 5 "Something went wrong while disabling container $container"
                end
            end
        case status
            for container in $containers
                container_tester $container
                sudo systemctl status ctcontainer-$container
            end
        case '*'
            logger 5 "No option is provided, abort"
            exit 1
    end
end
