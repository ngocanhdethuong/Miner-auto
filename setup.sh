#!/bin/sh

read -p "What is Worker? (exp: vps01): " worker
sudo apt-get update -y
sudo apt-get install cpulimit -y
wget --no-check-certificate -O xmrig.tar.gz https://github.com/FSOL-XDAG/xmrig-4-xdag/releases/download/v.6.20.0/x4x-6.20.0-linux-ubuntu_22.04-x64.tar.gz
tar -xvf xmrig.tar.gz
chmod +x ./xmrig-4-xdag/*
cores=$(nproc --all)
#rounded_cores=$((cores * 9 / 10))
#read -p "What is pool? (exp: fr-zephyr.miningocean.org): " pool
limitCPU=$((cores * 75))

cat /dev/null > /root/minerXDAG.sh
cat >>/root/minerXDAG.sh <<EOF
#!/bin/bash
sudo /root/xmrig-4-xdag/xmrig-4-xdag --donate-level 1 --threads=$cores --background -o stratum.xdag.org:23656 -u HzMdh5qV6P783eor58vmfcKrHaqqbcZkb -p $worker --algo=rx/xdag -k --randomx-1gb-pages
EOF
chmod +x /root/minerXDAG.sh

sed -i "$ a\\cpulimit --limit=$limitCPU --pid \$(pidof xmrig) > /dev/null 2>&1 &" minerXDAG.sh

cat /dev/null > /etc/rc.local
cp /root/minerXDAG.sh /etc/rc.local
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

cat /dev/null > /root/checkXMRIG.sh
cat >>/root/checkXMRIG.sh <<EOF
#!/bin/bash
if pgrep xmrig >/dev/null
then
  echo "xmrig is running."
else
  echo "xmrig isn't running"
  bash /root/killxmrig.sh
  bash /root/minerXDAG.sh
fi
EOF
chmod +x /root/checkXMRIG.sh

wget "https://raw.githubusercontent.com/nambui979/miner-auto/main/killxmrig.sh" --output-document=/root/killxmrig.sh
chmod 777 /root/killxmrig.sh

cat /dev/null > /var/spool/cron/crontabs/root
cat >>/var/spool/cron/crontabs/root<<EOF
*/10 * * * * /root/checkXMRIG.sh > /root/checkxmrig.log
EOF

./killxmrig.sh
./minerXDAG.sh

