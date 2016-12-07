#!/bin/bash

set | grep GIT
if [ ! -f $GITBLIT_HOME/data/gitblit.properties ]; then
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
