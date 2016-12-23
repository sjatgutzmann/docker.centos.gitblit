#!Dockerfile
FROM sjatgutzmann/docker.centos.oraclejava8

MAINTAINER Sven Jörns <sjatgutzmann@gmail.com>

ENV GITBLIT_VERSION 1.8.0

RUN yum -y update; yum clean all \
 && yum -y install git \
 && yum clean all

# Install Gitblit

WORKDIR /opt
RUN wget -O /tmp/gitblit.tar.gz http://dl.bintray.com/gitblit/releases/gitblit-${GITBLIT_VERSION}.tar.gz \
	&& tar xzf /tmp/gitblit.tar.gz \
	&& rm -f /tmp/gitblit.tar.gz \
	&& mv gitblit-${GITBLIT_VERSION} gitblit \ 
	&& ln -s gitblit gitblit-${GITBLIT_VERSION} \
	&& mv gitblit/data gitblit/data-initial 
#	&& mkdir gitblit-data

# checking in run.sh, if is data into data, if not, copy it
# https://github.com/docker/docker/issues/2259
# workaround: chmod 777
VOLUME /opt/gitblit/data
RUN chmod 777 /opt/gitblit/data
# user rights allways from host and with init this, it get root
ENV GITBLIT_USER gitblit
ENV GITBLIT_GROUP gitblit
ENV GITBLIT_HOME /opt/gitblit
RUN groupadd -r -g 500 ${GITBLIT_GROUP} \
	&& useradd -r -d ${GITBLIT_HOME} -u 500 -g 500 ${GITBLIT_USER} \
	&& chown -Rf ${GITBLIT_USER}:${GITBLIT_GROUP} ${GITBLIT_HOME}

COPY run.sh /run.sh
USER ${GITBLIT_USER}
# Adjust the default Gitblit settings to bind to 8080, 8443, 9418, 29418, and allow RPC administration.
# list of possible properties http://gitblit.com/properties.html
ENV HTTP_PORT 9080
ENV HTTPS_PORT 9443
# Enable Ticketservice
ENV TICKET_SERVICE com.gitblit.tickets.BranchTicketService
ENV FEDERATION_PASS gitblitdefault20161223
RUN echo "server.httpPort=${HTTP_PORT}" >> gitblit/data-initial/gitblit.properties \
	&& echo "server.httpsPort=${HTTPS_PORT}" >> gitblit/data-initial/gitblit.properties \
	&& echo "web.enableRpcManagement=true" >> gitblit/data-initial/gitblit.properties \
	&& echo "web.enableRpcAdministration=true" >> gitblit/data-initial/gitblit.properties \
	&& echo "git.enableGitServlet=true" >> gitblit/data-initial/gitblit.properties \
	&& echo "federation.passphrase=${FEDERATION_PASS}" >> gitblit/data-initial/gitblit.properties \
	&& echo "tickets.service=${TICKET_SERVICE}" >> gitblit/data-initial/gitblit.properties

EXPOSE ${HTTP_PORT} ${HTTPS_PORT} 9418 29418

WORKDIR ${GITBLIT_HOME}
USER root
ENTRYPOINT /run.sh
