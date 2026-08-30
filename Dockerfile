FROM php:8.1-apache-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    zip \
    tar \
    gzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libc-client-dev \
    libkrb5-dev \
    libicu-dev \
    libssl-dev \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-configure imap \
        --with-kerberos \
        --with-imap-ssl \
    && docker-php-ext-install -j"$(nproc)" \
        gd \
        imap \
        zip \
        mysqli \
        pdo_mysql \
        soap \
        intl \
        bcmath \
        opcache \
        mbstring \
        curl \
        xml \
        exif

RUN a2enmod rewrite headers expires

RUN { \
        echo "memory_limit=512M"; \
        echo "max_execution_time=600"; \
        echo "max_input_time=600"; \
        echo "upload_max_filesize=100M"; \
        echo "post_max_size=100M"; \
        echo "max_input_vars=10000"; \
        echo "short_open_tag=Off"; \
        echo "display_errors=Off"; \
        echo "log_errors=On"; \
        echo "date.timezone=Asia/Kolkata"; \
    } > /usr/local/etc/php/conf.d/vtiger.ini

WORKDIR /opt/vtiger

RUN curl -L \
    "https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%208.4.0/Core%20Product/vtigercrm8.4.0.tar.gz/download" \
    -o /tmp/vtigercrm.tar.gz \
    && mkdir -p /opt/vtiger \
    && tar -xzf /tmp/vtigercrm.tar.gz --strip-components=1 -C /opt/vtiger \
    && rm -f /tmp/vtigercrm.tar.gz

RUN mkdir -p \
    /opt/vtiger/cache \
    /opt/vtiger/storage \
    /opt/vtiger/logs \
    /opt/vtiger/test

RUN chown -R www-data:www-data /opt/vtiger \
    && chmod -R 775 /opt/vtiger

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["apache2-foreground"]
