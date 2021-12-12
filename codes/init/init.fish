function init
set container $argv[1]
set_color yellow
echo "$prefix Deploying..."
cd /opt
if sudo -E curl -s -L -o $container.tar.gz https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/$container.tar.gz
  sudo mkdir -p ctcontainer/$container
  sudo mv $container.tar.gz ctcontainer/$container
  cd ctcontainer/$container
  sudo tar xf $container.tar.gz
  sudo sh -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
  set_color green
  echo "$prefix $container deployed in /opt/ctcontainer/$container"
  set_color normal
else
  set_color red
  echo "$prefix Failed,check your network connective"
  set_color normal
end
end
