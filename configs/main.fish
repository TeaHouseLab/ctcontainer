set prefix [ctcontainer]
if test -d /etc/centerlinux/conf.d/
else
  sudo mkdir -p /etc/centerlinux/conf.d/
end
if test -e /etc/centerlinux/conf.d/ctcontainer.conf
  set ctcontainer_root (sed -n '/ctcontainer_root=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/ctcontainer_root=//g')
  set ctcontainer_share (sed -n '/ctcontainer_share=/'p /etc/centerlinux/conf.d/ctcontainer.conf | sed 's/ctcontainer_share=//g')
  set_color yellow
  echo "$prefix [debug] set root.ctcontainer -> $ctcontainer_root"
  echo "$prefix [debug] set share.ctcontainer -> $ctcontainer_share"
  set_color normal
else
  ctconfig_init
end
switch $argv[1]
case purge
  purge $argv[2]
case init
  init $argv[2]
case run
  run $argv[2] $argv[3..-1]
case list
  list
case v version
  set_color yellow
  echo "FrostFlower@build0"
  set_color normal
case install
  install ctcontainer
case uninstall
  uninstall ctcontainer
case h help '*'
  help_echo
end
