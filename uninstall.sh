sudo systemctl stop ly
sudo systemctl disable ly

sudo rm -fv /usr/bin/ly
sudo rm -rfv /etc/ly
sudo rm -fv /etc/pam.d/ly
sudo rm -fv /usr/lib/systemd/system/ly.service