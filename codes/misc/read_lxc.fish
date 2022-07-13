function read_lxc
    if test $ctcontainer_source = ""
        logger 5 "No remote repo is configured, abort"
        logger 5 "Please configure it in /etc/centerlinux/conf.d/ctcontainer.conf"
        exit
    end
    set image (curl -sL $ctcontainer_source/streams/v1/images.json | jq -r '.products')
    switch $argv[1]
        case all_images
            echo $image | jq -r 'keys | .[]' | sed 's/\:/-/g'
        case get_path
            set container $argv[2]
            set container_item (echo $container | sed 's/-/\:/g')
            set latest (echo $image | jq -r ".[\"$container_item\"].versions|keys|.[]" | tail -n1)
            echo $image | jq -r ".[\"$container_item\"].versions|.[\"$latest\"].items |.[\"root.tar.xz\"].path"
    end
end
