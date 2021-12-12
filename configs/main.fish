set prefix [ctcontainer]
switch $argv[1]
case purge
  purge $argv[1]
case init
  init $argv[2]
case run
  run $argv[2] $argv[3]
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
