#!/bin/sh
set -ex
echo "========================================================"
if [ -f '/tmp/docker-init' ]; then
    echo "已初始化，跳过"
    exit 0
fi

echo "禁止clear_env"
sed -i "s/;clear_env = no/clear_env = no/g" /opt/bitnami/php/etc/php-fpm.d/www.conf

#echo "调整报错级别"
#sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ERROR/g" /opt/bitnami/php/lib/php.ini
#echo "开启pdo_pgsql扩展"
#echo "extension = pdo_pgsql" >> /opt/bitnami/php/lib/php.ini


echo "创建nginx日志目录"
mkdir -p /var/log/nginx
mkdir -p /var/log/php-fpm

echo "========================================================"
echo "创建/tmp/docker-init"
touch /tmp/docker-init
