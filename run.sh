#!/bin/bash

set | grep GIT
if [ ! -f $GITBLIT_HOME/data/gitblit.properties ]; then
	echo "server.httpPort=${HTTP_PORT}" >> $GITBLIT_HOME/data-initial/gitblit.properties \
        && echo "server.httpsPort=${HTTPS_PORT}" >> $GITBLIT_HOME/data-initial/gitblit.properties \
        && echo "web.enableRpcManagement=true" >> $GITBLIT_HOME/data-initial/gitblit.properties \
        && echo "web.enableRpcAdministration=true" >> $GITBLIT_HOME/data-initial/gitblit.properties \
        && echo "git.enableGitServlet=true" >> $GITBLIT_HOME/data-initial/gitblit.properties \
        && echo "federation.passphrase=${FEDERATION_PASS}" >> $GITBLIT_HOME/data-initial/gitblit.properties \
        && echo "tickets.service=${TICKET_SERVICE}" >> $GITBLIT_HOME/data-initial/gitblit.properties
	if [ $FEDERATION1_MIRROR ]; then
		mirrorNr=1
		echo "federation.${mirrorNr}.url = ${FEDERATION1_URL}" >> $GITBLIT_HOME/data-initial/gitblit.properties \
		&& echo "federation.${mirrorNr}.token = ${FEDERATION1_TOKEN}" >> $GITBLIT_HOME/data-initial/gitblit.properties \
		&& echo "federation.${mirrorNr}.frequency = ${FEDERATION1_TIME:-120 mins}" >> $GITBLIT_HOME/data-initial/gitblit.properties \
		&& echo "federation.${mirrorNr}.bare = $FEDERATION1_BARE" >> $GITBLIT_HOME/data-initial/gitblit.properties \
		&& echo "federation.${mirrorNr}.mergeAccounts = $FEDERATION1_MERGE_ACCOUNTS" >> $GITBLIT_HOME/data-initial/gitblit.properties \
		&& echo "federation.${mirrorNr}.folder = ${FEDERATION1_FOLDER}" >> $GITBLIT_HOME/data-initial/gitblit.properties \
		&& echo "federation.${mirrorNr}.mirror = $FEDERATION1_MIRROR" >> $GITBLIT_HOME/data-initial/gitblit.properties 
	fi
	cp -af $GITBLIT_HOME/data-initial/* $GITBLIT_HOME/data/ \
	&& chown -Rf $GITBLIT_USER:$GITBLIT_GROUP $GITBLIT_HOME/data/
fi

if [ -z "$JAVA_OPTS" ]; then
	JAVA_OPTS="-server -Xmx1024m"
fi

#chown -Rf gitblit:gitblit /opt/gitblit-data

#exec sudo -u gitblit java $JAVA_OPTS -Djava.awt.headless=true -jar /opt/gitblit/gitblit.jar --baseFolder /opt/gitblit-data

# starting with user gitblit
cd $GITBLIT_HOME
exec su $GITBLIT_USER -c "java $JAVA_OPTS -Djava.awt.headless=true -jar $GITBLIT_HOME/gitblit.jar --baseFolder $GITBLIT_HOME/data"
