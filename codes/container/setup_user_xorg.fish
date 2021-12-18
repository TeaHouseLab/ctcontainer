function setup_user_xorg
set container $argv[1]
if test -d $ctcontainer_root/$container/tmp/.X11-unix
else
  sudo mkdir -p $ctcontainer_root/$container/tmp/.X11-unix
end
if command -q -v xhost
  xhost +local:
else
  set_color red
  echo "$prefix [error] Xhost not found,xorg in container couldn't be set up,still try to mount the .X11-unix directory"
  set_color normal
end
sudo mount -o rbind /tmp/.X11-unix $ctcontainer_root/$container/tmp/.X11-unix
end
