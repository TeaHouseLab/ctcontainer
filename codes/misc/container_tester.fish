function container_tester
    set container $argv[1]
    if [ "$container" = "" ]
        logger 5 "Nothing selected , abort"
        exit 1
    else
        if test -d $ctcontainer_root/$container; and test -r $ctcontainer_root/$container
        else
            logger 5 "Container $container does not exist,abort,check your container list,or probably there's a incorrect option is provided"
            exit 1
        end
    end
end
