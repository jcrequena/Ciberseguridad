sudo apt update -y && apt upgrade -y
sudo apt install unbound libtool
git clone https://github.com/openvswitch/ovs.git
cd ovs/
sudo ./boot.sh
sudo ./configure
sudo make
sudo apt install make
sudo /sbin/modprobe openvswitch
sudo /sbin/lsmod | grep openvswitch
export PATH=$PATH:/usr/local/share/openvswitch/scripts
sudo ovs-ctl start
ovs-vsctl show

ovs-vsctl add-br ciber-bridge
ovs-vsctl add-port ciber-bridge enp0s8
ovs-vsctl add-port ciber-bridge enp0s9

ovs-vsctl set-port enp0s8 tag=10
ovs-vsctl set-port enp0s8 tag=10
ovs-vsctl set-port enp0s9 tag=10
ovs-appctl fdb/show ciber-bridge

#Borrar puertos
ovs-vsctl del-port ciber-bridge enp0s8
ovs-vsctl del-port ciber-bridge enp0s9

