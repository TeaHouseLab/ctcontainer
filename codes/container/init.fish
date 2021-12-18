function init
set container $argv[1]
set containername $container
set_color yellow
echo "$prefix Deploying..."
set_color normal
cd $ctcontainer_root
if echo $argv[2..-1] | grep -q -i '\-f'
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
if sudo -E curl -s -L -o $container.tar.gz https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/$container.tar.gz
  set_color green
  echo "$prefix $container Package downloaded"
  set_color normal
  sudo mkdir -p $containername
  sudo mv $container.tar.gz $containername
  cd $containername
  sudo tar xf $container.tar.gz
  sudo sh -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
  set_color green
  echo "$prefix $container deployed in $ctcontainer_root/$containername"
  set_color normal
else
  set_color red
  echo "$prefix Failed,check your network connective"
  set_color normal
end
end
