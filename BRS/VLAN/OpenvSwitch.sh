sudo apt update -y && apt upgrade -y
sudo apt install libtool
git clone https://github.com/openvswitch/ovs.git
cd ovs/
sudo ./boot.sh
sudo ./configure
sudo make
sudo apt install make
sudo /sbin/modprobe openvswitch
sudo /sbin/lsmod | grep openvswitch
export PATH=$PATH:/usr/local/share/openvswitch/scripts

sudo snap install openvswitch --edge

http://golanzakai.blogspot.com/2012/01/openvswitch-with-virtualbox.html

sudo ovs-ctl start
ovs-vsctl show

ovs-vsctl add-br lan0

for tap in `seq 0 7`; do
  ip tuntap add mode tap lan0p$tap
done;
ip tuntap list

for tap in `seq 0 7`; do 
        ip link set lan0p$tap up
done;

for tap in `seq 0 7`; do
        ovs-vsctl add-port lan0 lan0p$tap
done;
ovs-vsctl list-ports lan0


#ovs-vsctl add-port ciber-bridge enp0s8
#ovs-vsctl add-port ciber-bridge enp0s9

#ovs-vsctl set-port enp0s8 tag=10
#ovs-vsctl set-port enp0s8 tag=10
#ovs-vsctl set-port enp0s9 tag=10
ovs-appctl fdb/show ciber-bridge

#Borrar puertos
ovs-vsctl del-port ciber-bridge enp0s8
ovs-vsctl del-port ciber-bridge enp0s9

