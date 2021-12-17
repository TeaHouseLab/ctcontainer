function init
set container $argv[1]
set_color yellow
echo "$prefix Deploying..."
cd $ctcontainer_root
if sudo -E curl -s -L -o $container.tar.gz https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/$container.tar.gz
  sudo mkdir -p $container
  sudo mv $container.tar.gz $container
  cd $container
  sudo tar xf $container.tar.gz
  sudo sh -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
  set_color green
  echo "$prefix $container deployed in $ctcontainer_root/$container"
  set_color normal
else
  set_color red
  echo "$prefix Failed,check your network connective"
  set_color normal
end
end
