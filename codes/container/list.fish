function list
echo ">Available<"
curl -s -L https://github.com/TeaHouseLab/FileCloud/releases/download/ctcontainer/available
echo
echo ">Installed<"
list_menu $ctcontainer_root
end
