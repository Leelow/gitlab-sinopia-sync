FROM gitlab/gitlab-ce:latest

# Install nodejs 5.x
RUN sudo apt-get -y install curl
RUN sudo curl --silent --location https://deb.nodesource.com/setup_5.x | sudo -E bash -
RUN sudo apt-get -y install nodejs

# Install latest version of npm
RUN sudo curl -L https://www.npmjs.com/install.sh | sh

# Install supervisor
RUN sudo apt-get install -y supervisor

# Create supervisor dir for gitlab and sinopia
RUN mkdir -p /var/run/gitlab /var/run/sinopia /var/log/supervisor

# Add supervisor conf
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add gitlab assets (https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/docker/assets)
COPY files/assets/wrapper /usr/local/bin/

# Install sinopia forked from https://github.com/Leelow/sinopia
WORKDIR /var/opt
RUN git clone --depth 1 https://github.com/Leelow/sinopia.git
WORKDIR /var/opt/sinopia
RUN npm install --production && npm cache clean

# Add sinopia config
COPY files/config.yaml sinopia/config.yaml

# Expose sinopia port
EXPOSE 4873

# Add sinopia volume
VOLUME /var/opt/sinopia/sinopia

# Install gitlab-webhook-publish
WORKDIR /var/opt
RUN git clone --depth 1 https://github.com/Leelow/gitlab-webhook-publish.git
WORKDIR /var/opt/gitlab-webhook-publish
RUN npm install --production && npm cache clean
RUN chmod +x bin/gwp

# Add gitlab-webhook-publish config
COPY files/local.json config/local.json

# Install gitlab-webhook-publish configurator
COPY files/configurator /var/opt/configurator
WORKDIR /var/opt/configurator
RUN npm install --production && npm cache clean

# Trick to avoid sinopia dir bug
WORKDIR /var/opt/sinopia

# Overrides gitlab-ce CMD : https://hub.docker.com/r/gitlab/gitlab-ce/~/dockerfile/ running supervisor instead
CMD ["/usr/bin/supervisord"]