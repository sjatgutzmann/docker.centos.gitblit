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
# set passfrase of this gitblit server -> generate a token to access this server
ENV FEDERATION_PASS gitblitdefault20161223
# properties to connect to another gitblit server
ENV FEDERATION1_MIRROR true
ENV FEDERATION1_BARE true
ENV FEDERATION1_MERGE_ACCOUNTS true
ENV FEDERATION1_URL https://dev.gitblit.com
ENV FEDERATION1_TOKEN 6f3b8a24bf970f17289b234284c94f43eb42f0e4
ENV FEDERATION1_TIME="120 mins"
ENV FEDERATION1_FOLDER="gitblit"
#bypass certificate verification
RUN git config --global --bool --add http.sslVerify false

EXPOSE ${HTTP_PORT} ${HTTPS_PORT} 9418 29418

WORKDIR ${GITBLIT_HOME}
USER root
ENTRYPOINT /run.sh
