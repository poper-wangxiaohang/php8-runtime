#!/bin/sh
set -ex

if [ -f '/init.sh' ]; then
    /bin/sh /init.sh
fi

php-fpm
nginx -g "daemon off;"
