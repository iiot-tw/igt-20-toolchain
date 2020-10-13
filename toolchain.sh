#!/bin/bash
USER_NAME=neousys
USER_CONFIG_FOLDER_OPENBOX="/home/${USER_NAME}/.config/openbox"
USER_WORKSPACE_FOLDER_ECLIPSE="/home/${USER_NAME}/workspace"
APT_SOURCES_LIST_ADD="/etc/apt/sources.list.d/neousys-cc.list"
SUDOER_ADD="/etc/sudoers.d/neousys-cc-sudoer"
ECLIPSE_NAME="eclipse-cpp-luna-SR2-linux-gtk-x86_64.tar.gz"
ECLIPSE_DOWNLOAD_ADDR="http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/luna/SR2/${ECLIPSE_NAME}"

echo "installing cross-compiler"
apt-get -y install build-essential
#emdebian site no logger supported, but debian repo does
#echo "deb http://emdebian.org/tools/debian jessie main" > ${APT_SOURCES_LIST_ADD}
#wget http://emdebian.org/tools/debian/emdebian-toolchain-archive.key
#apt-key add emdebian-toolchain-archive.key
dpkg --add-architecture armhf
apt-get update
apt-get -y install crossbuild-essential-armhf gdb-multiarch

echo "installing Eclipse"
apt-get -y install lightdm openbox default-jre

if ! [ -e "$ECLIPSE_NAME" ]; then
	wget ${ECLIPSE_DOWNLOAD_ADDR}
fi

tar -xvf ${ECLIPSE_NAME} -C /usr/share
ln -s /usr/share/eclipse/eclipse /usr/bin/eclipse
sed -i "s/#autologin-user=.*/autologin-user=neousys/g" /etc/lightdm/lightdm.conf

echo "setting up environment"
mkdir -p "${USER_WORKSPACE_FOLDER_ECLIPSE}"
chown neousys:neousys "${USER_WORKSPACE_FOLDER_ECLIPSE}"
echo "set architecture arm" >> "${USER_WORKSPACE_FOLDER_ECLIPSE}"/.gdbinit
apt-get -y install sudo
cat <<-EOF > "${SUDOER_ADD}"
neousys ALL=(ALL) NOPASSWD: /sbin/shutdown
EOF

mkdir -p "${USER_CONFIG_FOLDER_OPENBOX}"
cat <<-EOF > "${USER_CONFIG_FOLDER_OPENBOX}/autostart"
eclipse
sudo shutdown -h now
EOF

cat <<-"EOF" > "${USER_CONFIG_FOLDER_OPENBOX}/menu.xml"
<?xml version="1.0" encoding="UTF-8"?>

<openbox_menu xmlns="http://openbox.org/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://openbox.org/
                file:///usr/share/openbox/menu.xsd">

<menu id="root-menu" label="Openbox 3">
  <item label="Terminal emulator">
    <action name="Execute"><execute>x-terminal-emulator</execute></action>
  </item>
  <item label="Web browser">
    <action name="Execute"><execute>x-www-browser</execute></action>
  </item>
  <!-- This requires the presence of the 'menu' package to work -->
  <menu id="/Debian" />
  <separator />
  <menu id="client-list-menu" />
  <separator />
  <item label="ObConf">
    <action name="Execute"><execute>obconf</execute></action>
  </item>
  <item label="Reboot">
    <action name="Execute">
    	<prompt>Are you sure to reboot?</prompt>
	<execute>sudo shutdown -r now</execute>
    </action>
  </item>
  <item label="Shutdown">
    <action name="Execute">
    	<prompt>Are you sure to shutdown?</prompt>
	<execute>sudo shutdown -h now</execute>
    </action>
  </item>
  <separator />
  <item label="Exit">
    <action name="Exit" />
  </item>
</menu>

</openbox_menu>
EOF
