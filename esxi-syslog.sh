esxcli system syslog config set --loghost='udp://logs.conoso.ru:41514'
esxcli system syslog reload

cp /etc/vmware/firewall/service.xml /etc/vmware/firewall/service.xml.bak
chmod 644 /etc/vmware/firewall/service.xml
chmod +t /etc/vmware/firewall/service.xml

sed -i '/<\/ConfigRoot>/d' /etc/vmware/firewall/service.xml

cat <<EOT >> /etc/vmware/firewall/service.xml
<service id="0041">
<id>CustomSyslog</id>
<rule id='0000'>
<direction>outbound</direction>
<protocol>udp</protocol>
<porttype>dst</porttype>
<port>41514</port>
</rule>
<enabled>true</enabled>
<required>false</required>
</service>
</ConfigRoot>
EOT

chmod 444 /etc/vmware/firewall/service.xml
esxcli network firewall refresh