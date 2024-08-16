#!/bin/bash

# 将ssh公钥复制到vps，并关闭密码登录

# 如果非root登录则退出

if [ "$UID" -ne 0 ]; then
    echo "必须以root用户执行此脚本"
    exit
fi

public_key='ecdsa-sha2-nistp521 ABAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFmPL1n/Kzr1YjprLpR1MBcEQF9JmSKZ+Wsj7oXmg/cXfaavFdr6UQBES8j5wt/mxbGKrRXWE/3egF8YHZzm77axAHEtWgbOAo3tcaLyJ8t7PKM8/BOK3hlFB32SREtbZgm1RjEVoeR9F8Qj8L24Fbf7v7I8jspBeADbKF1AYSmo+QeaQ=='

# 添加公钥
# 有authorized_keys文件，没有公钥才添加
# 没有authorized_keys文件，创建并添加

if [ -e /root/.ssh/authorized_keys ]; then
    result=$(cat /root/.ssh/authorized_keys | grep "${public_key:8:20}")
    if [ "$result" != "" ]; then
        echo "已有此公钥"
    else
        echo $public_key >> /root/.ssh/authorized_keys
    fi
else
    mkdir /root/.ssh
    touch /root/.ssh/authorized_keys
    echo $public_key >> /root/.ssh/authorized_keys
fi

# 修改ssh配置文件

sed -e '/PubkeyAuthentication/cPubkeyAuthentication yes' \
    -e '#AuthorizedKeysFile#cAuthorizedKeysFile .ssh/authorized_keys' \
    -e '/PermitRootLogin/cPermitRootLogin yes' \
    -e '/PasswordAuthentication/cPasswordAuthentication no' \
    -i /etc/ssh/sshd_config

result=$(cat /etc/ssh/sshd_config | grep "RSAAuthentication yes")

if [ "$result" = "" ]; then
    echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
fi

service sshd restart
