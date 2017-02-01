#!/usr/bin/env bash

echo "=== Starting provision script..."

cd /vagrant

echo "=== Adding 'cd /vagrant' to .profile"
cat >> /home/vagrant/.profile <<EOL

cd /vagrant
EOL

echo "=== Updating apt..."
apt-get update >/dev/null 2>&1

# Used in many dependencies:
apt-get install python-software-properties curl -y

echo "=== Installing Haxe targets:"

echo "=== Installing C++..."
apt-get install -y gcc-multilib g++-multilib
haxelib install hxcpp >/dev/null 2>&1

echo "=== Installing C#..."
apt-get install -y mono-devel mono-mcs
haxelib install hxcs >/dev/null 2>&1

echo "=== Installing Java..."
haxelib install hxjava >/dev/null 2>&1

echo "=== Installing PHP..."
apt-get install -y php5-cli

echo "=== Installing Flash (xvfb)..."
apt-get install -y xvfb

echo "=== Installing Node.js..."
curl --silent --location https://deb.nodesource.com/setup_4.x | sudo bash -
apt-get install nodejs -y
# npm config set spin=false

echo "=== Installing Phantomjs (js testing)..."
npm install -g phantomjs-prebuilt

echo "=== Installing Python 3.4..."
add-apt-repository ppa:fkrull/deadsnakes -y
apt-get update
apt-get install python3.4 -y
ln -s /usr/bin/python3.4 /usr/bin/python3

echo "=== Installing Java 8 JDK (openjdk)..."
add-apt-repository ppa:openjdk-r/ppa -y
apt-get update
apt-get install openjdk-8-jdk -y

echo "If you have several java versions and want to switch:"
echo "sudo update-alternatives --config java"
echo "sudo update-alternatives --config javac"
echo ""
echo "Current java version:"
java -version

echo "=== Installing Lua..."
apt-get -y install lua5.2 make unzip libpcre3 libpcre3-dev

# Add source files so luarocks works
mkdir -p /usr/include/lua/5.2
wget -q http://www.lua.org/ftp/lua-5.2.0.tar.gz
tar xf lua-5.2.0.tar.gz
cp lua-5.2.0/src/* /usr/include/lua/5.2/
rm -rf lua-5.2.0
rm -f lua-5.2.0.tar.gz

# Compile luarocks itself
wget -q http://luarocks.org/releases/luarocks-2.3.0.tar.gz
tar zxpf luarocks-2.3.0.tar.gz
cd luarocks-2.3.0
./configure >/dev/null 2>&1
make build >/dev/null 2>&1
make install >/dev/null 2>&1
cd ..
rm -f luarocks-2.3.0.tar.gz
rm -rf luarocks-2.3.0

# Install lua libraries so it works with Haxe
luarocks install lrexlib-pcre 2.7.2-1
luarocks install luafilesystem

echo "=== Installing Haxe 3.2.1..."
wget -q http://ciscoheat.github.io/cdn/haxe/haxe-3.2.1-linux-installer.sh
sh haxe-3.2.1-linux-installer.sh -y >/dev/null 2>&1
rm -f haxe-3.2.1-linux-installer.sh

echo /usr/lib/haxe/lib/ | haxelib setup
echo /usr/lib/haxe/lib/ > /home/vagrant/.haxelib
chown vagrant:vagrant /home/vagrant/.haxelib
sed -i 's/precise64/mithril/g' /etc/hostname /etc/hosts

echo "=== Provision script finished!"
echo "Change timezone: sudo dpkg-reconfigure tzdata"
echo "Change hostname: sudo pico /etc/hostname && sudo pico /etc/hosts"
echo ""
echo "Execute 'vagrant reload' to rename the VM and complete the process."
