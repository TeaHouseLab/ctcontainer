Ctcontainer
=
<img src="https://github.com/TeaHouseLab/TeaHouseArtworks/blob/main/OtherProjects/ctcontainer.svg?raw=true" alt="logo" style="width:256px;"/>

Ctcontainer is a chroot/nspawn container manager system, which mostly used on **NON-Production** environment such as PC and laptop

![Learn more at the project page](https://ruzhtw.top/pages/projects/CenterLinux/ctcontainer)

# Must-know before using
1. ctcontainer is not a **Virtual Machine**, it just a container like docker but with less restriction
2. ctcontainer is not a **sandbox**, run virus on it is **extremly dangerous**, I'm not responsible to the damage of your system caused by that, the safety level depends on your settings and the backend(currently systemd-nspawn or chroot)