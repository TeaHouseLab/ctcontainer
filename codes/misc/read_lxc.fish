function read_lxc
    if test -z "$ctcontainer_source"
        logger 5 "No remote repo is configured, abort"
        logger 5 "Please configure source= in /etc/centerlinux/conf.d/ctcontainer.conf"
        exit
    end
    set image (curl -sL $ctcontainer_source/streams/v1/images.json | jq -r '.products')
    switch $argv[1]
        case all_images
            echo $image | jq -r 'keys | .[]'
        case get_path
            set container $argv[2]
            set latest (echo $image | jq -r ".[\"$container\"].versions|keys|.[]" | tail -n1)
            echo $image | jq -r ".[\"$container\"].versions|.[\"$latest\"].items |.[\"root.tar.xz\"].path"
    end
end
