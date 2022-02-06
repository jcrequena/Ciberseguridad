sudo add-apt-repository ppa:gns3/ppa
sudo apt update
sudo apt upgrade
sudo apt install gns3-gui gns3-server
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install gns3-iou
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce

usermod -aG ubridge jcrequena
usermod -aG libvirt jcrequena
usermod -aG kvm jcrequena
usermod -aG wireshark jcrequena
usermod -aG docker jcrequena
