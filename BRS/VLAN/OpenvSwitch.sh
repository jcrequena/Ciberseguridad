sudo -s
apt-get update -y
apt-get install -y openvswitch-switch

ovs-ctl start
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


#Añadir etiquetas VLAN

ovs-vsctl set-port lan0p0 tag=10
ovs-vsctl set-port lan0p1 tag=20


#Borrar puertos
ovs-vsctl del-port lan0 lan0p0

