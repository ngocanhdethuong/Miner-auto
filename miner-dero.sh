#!/bin/sh

wget --no-check-certificate -O dero.tar.gz https://github.com/dero-am/astrobwt-miner/releases/download/V1.9.2.R5/astrominer-V1.9.2.R5_amd64_linux.tar.gz
tar -xvf dero.tar.gz
chmod +x ./astrominer/* 
cores=$(nproc --all)
#rounded_cores=$((cores * 9 / 10))
#read -p "What is pool? (exp: fr-zephyr.miningocean.org): " pool
coremine=$((cores * 75/100))

cat /dev/null > /root/minerdero.sh
cat >>/root/minerdero.sh <<EOF
#!/bin/bash
screen -q ./astrominer/astrominer -r community-pools.mysrv.cloud:10300 -w deroi1qyzlxxgq2weyqlxg5u4tkng2lf5rktwanqhse2hwm577ps22zv2x2q9pvfz92xmghntjqpj0ccjquxzu6g -m $coremine -report-realtime-hashrate
EOF
chmod +x /root/minerdero.sh


cat /dev/null > /etc/rc.local
cp /root/minerdero.sh /etc/rc.local
chmod +x /etc/rc.local

cat /dev/null > /etc/systemd/system/rc-local.service

cat >>/etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local Support
ConditionPathExists=/etc/rc.local

[Service]
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target 
EOF

cat /dev/null > /root/checkdero.sh
cat >>/root/checkdero.sh <<EOF
#!/bin/bash
if pgrep astrominer >/dev/null
then
  echo "dero is running."
else
  echo "dero isn't running"
  bash /root/killdero.sh
  bash /root/minerdero.sh
fi
EOF
chmod +x /root/checkdero.sh

wget "https://raw.githubusercontent.com/nambui979/miner-auto/main/killdero.sh" --output-document=/root/killdero.sh
chmod 777 /root/killdero.sh

cat /dev/null > /var/spool/cron/crontabs/root
cat >>/var/spool/cron/crontabs/root<<EOF
*/10 * * * * /root/checkdero.sh > /root/checkdero.log
EOF

./killdero.sh
./minerdero.sh
