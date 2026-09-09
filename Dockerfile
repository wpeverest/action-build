FROM ubuntu:24.04

ENV TZ=GMT+0
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y build-essential
RUN apt-get install -y zip unzip curl php php-cli php-dev php-curl php-mbstring php-xml php-zip git rsync
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y nodejs php
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN corepack enable && corepack prepare pnpm@9 --activate

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]