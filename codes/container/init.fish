function init
set initraid (random 1000 1 9999)
set container $argv[1]
set_color yellow
echo "$prefix Deploying..."
set_color normal
cd $ctcontainer_root
while test -d $container-$initraid
set_color red
echo "$prefix [warning] The random container name has existed,generating a new one"
set_color normal
set initraid (random 1000 1 9999)
end
if sudo -E curl -s -L -o $container.tar.gz https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/$container.tar.gz
  set_color green
  echo "$prefix $container Package downloaded"
  set_color normal
  sudo mkdir -p $container-$initraid
  sudo mv $container.tar.gz $container-$initraid
  cd $container-$initraid
  sudo tar xf $container.tar.gz
  sudo sh -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
  set_color green
  echo "$prefix $container deployed in $ctcontainer_root/$container-$initraid"
  set_color normal
else
  set_color red
  echo "$prefix Failed,check your network connective"
  set_color normal
end
end
