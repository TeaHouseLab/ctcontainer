function setup_network
    if test $ctcontainer_log_level = "debug"
        logger 3 "Starting Setup Nat network for guest machine"
    end
    if systemctl is-active --quiet systemd-networkd
    else
        if test (systemctl list-unit-files 'systemd-networkd*' | wc -l) -gt 3 
            sudo systemctl start systemd-networkd
        else
            logger 5 "Unable to setup network for guest machine, please install systemd-networkd on your host machine, abort"
            exit 128
        end
    end
end
