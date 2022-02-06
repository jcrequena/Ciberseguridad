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
#######################################################3
sudo -s
./ovs-ctl start
ovs-vsctl show
