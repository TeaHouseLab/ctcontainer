function purge
set container $argv[1]
cd $ctcontainer_root
  if test -d $container
    if sudo rm -rf $container
      set_color green
      echo "$prefix Purged $container"
      set_color normal
    else
      set_color red
      echo "$prefix Ouch!Something went wrong at {ctcontainer.purge.rm}"
      set_color normal
    end
  else
    set_color red
    echo "$prefix [error]No such container in root.ctcontainer"
    set_color normal
  end
end
