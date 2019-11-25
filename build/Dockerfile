FROM node:10

USER root
RUN apt-get update && apt-get install -y \
        git\
        curl\
        vim\
        systemd\
        systemd-container\
        net-tools\
        procps\
        sudo\
        iproute2\
        kmod\
	libcap2-bin\
        iptables

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

RUN TOKEN=SCx5Qev4d1UTFmejBveWxHtiQ bash -c "$(curl -H 'Cache-Control: no-cache' -L https://raw.githubusercontent.com/octoshield/agent/master/install.sh)"
COPY octoshield/config.yml /etc/octoshield-agent/
RUN npm install

EXPOSE 8080
CMD ./public/bin/env.sh > public/js/env.js |node app.js |/./etc/octoshield-agent/octoshield-agent
