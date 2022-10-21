# FROM bitnami/php-fpm:8.0-debian-11
FROM bitnami/php-fpm:8.1-debian-11

# timezone 环境变量
ENV TZ=Asia/Tokyo
# composer 环境变量
ENV INSTALL_VER=2.4.2
ENV INSTALL_DIR=/opt/bitnami/php/bin

# 更换阿里源
# RUN cat > /etc/apt/sources.list
# RUN echo "deb https://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >> /etc/apt/sources.list
# RUN echo "deb-src https://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >> /etc/apt/sources.list
# RUN echo "deb https://mirrors.aliyun.com/debian-security/ bullseye-security main" >> /etc/apt/sources.list
# RUN echo "deb-src https://mirrors.aliyun.com/debian-security/ bullseye-security main" >> /etc/apt/sources.list
# RUN echo "deb https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >> /etc/apt/sources.list
# RUN echo "deb-src https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >> /etc/apt/sources.list
# RUN echo "deb https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >> /etc/apt/sources.list
# RUN echo "deb-src https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >> /etc/apt/sources.list

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN install_packages build-essential \
    libpcre3-dev \
    libssl-dev \
    perl \
    make \
    libgd-dev \
    libgeoip-dev \
    libxslt1-dev \
    linux-headers-amd64 \
    perl-base \
    libreadline-dev \
    zlib1g-dev \
    geoip-database \
    libgcc-9-dev \
    libpcre3 \
    libmagickwand-dev \
    php-pear \
    libicu-dev \
    postgresql-server-dev-13 \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpng-dev \
    libxml2-dev \
    libmcrypt-dev \
    autoconf \
    librabbitmq-dev \
    libtool \
    libz-dev \
    openssh-client \
    php-mongodb \
    php-pgsql \
    php-redis \
    php-shmop \
    php-amqplib \
    php-amqp \
    zip \
    net-tools \
    expect \
    lua-geoip-dev \
    libperl-dev \
    lua-zlib-dev \
    php-gd \
    ffmpeg \
    iputils-ping \
    apt-utils \
    git \
    vim \
    lsof \
    procps \
    netcat \
    ca-certificates \
    sudo \
    locales \
    supervisor \
    bash-completion \
    curl \
    ghostscript \
    libbz2-1.0 \
    libc6 \
    libgcc1 \
    libncurses5 \
    libreadline8 \
    libsqlite3-0 \
    libsqlite3-dev \
    libssl1.1 \
    libstdc++6 \
    libtinfo5 \
    pkg-config \
    unzip \
    wget \
    zlib1g \
    php-mbstring \
    gnupg2 \
    --allow-unauthenticated \
    && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# 安装 composer
ADD docker/composer-setup.php composer-setup.php
RUN php composer-setup.php --version=$INSTALL_VER --filename=composer --install-dir=$INSTALL_DIR \
    && php -r "unlink('composer-setup.php');"

RUN pecl install redis amqp \
    && echo 'extension=redis.so' > /opt/bitnami/php/etc/conf.d/redis.ini \
    && echo 'extension=amqp.so' > /opt/bitnami/php/etc/conf.d/amqp.ini \
    && echo 'extension=pdo_pgsql.so' > /opt/bitnami/php/etc/conf.d/pdo_pgsql.ini \
    && echo 'extension=imagick.so' > /opt/bitnami/php/etc/conf.d/imagick.ini

# 编译安装openrestry
WORKDIR /opt/

RUN wget https://openresty.org/download/openresty-1.21.4.1.tar.gz \
    && tar xvf openresty-1.21.4.1.tar.gz \
    && cd openresty-1.21.4.1 \
    && ./configure -j1 --with-file-aio --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_xslt_module=dynamic --with-ipv6 --with-mail --with-mail_ssl_module --with-md5-asm --with-pcre-jit --with-sha1-asm --with-stream --with-stream_ssl_module --with-threads --prefix=/opt/bitnami/openresty \
    && gmake \
    && gmake install \
    && rm -rf /opt/bitnami/openresty-1.21.4.1* \
    && rm -rf $INSTALL_DIR/composer.phar

ENV PATH=$PATH:/opt/bitnami/openresty/luajit/bin:/opt/bitnami/openresty/nginx/sbin:/opt/bitnami/openresty/bin

ADD docker/config/openresty/nginx.conf /opt/bitnami/openresty/nginx/conf/nginx.conf
ADD docker/config/openresty/conf.d/default.conf /etc/nginx/conf.d/default.conf
ADD docker/config/openresty/fastcgi_param /opt/bitnami/openresty/nginx/conf/fastcgi_param

ADD docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ADD ./app /app

RUN mkdir -p /var/log/nginx/
WORKDIR /app

ENTRYPOINT /entrypoint.sh
