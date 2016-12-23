# Gitblit

This is a Docker image of Gitblit (http://gitblit.com/)
based on `sjatgutzmann/docker.centos.oraclejava8`

## Usage

```bash
docker run -d --name=gitblit \
	-p 8080:8080 -p 8443:8443 \
	-p 9418:9418 -p 29418:29418 \
	sjatgutzmann/docker.centos.gitblit
```

Gitblit interface should be available at http://127.0.0.1:8080/
(user/password: `admin`/`admin`)

By default it uses Docker data volume for persistence.

You can update such installation by passing `--volumes-from` option
to `docker run`:

```bash
docker pull sjatgutzmann/docker.centos.gitblit
docker stop gitblit
docker rename gitblit gitblit-old
docker run -d --name=gitblit \
	-p 8080:8080 -p 8443:8443 \
	-p 9418:9418 -p 29418:29418 \
	--volumes-from gitblit-old \
	sjatgutzmann/docker.centos.gitblit
docker rm -v gitblit-old
```

### Local storage

If you prefer to have direct access to container's data
from the host, you can use local storage instead of data volumes:

```bash
docker run -d --name=gitblit \
	-p 8080:8080 -p 8443:8443 \
	-p 9418:9418 -p 29418:29418 \
	-v /srv/gitblit:/opt/gitblit/data \
	sjatgutzmann/docker.centos.gitblit
```

`gitblit-data` volume will be automatically populated
with default configuration if necessary.

File ownership is recursively changed to
`gitblit:gitblit` (`500:500`) on each start.

### Configuration

You can configure the instance by editing files 
in directory /opt/gitblit/data inside the container
(or appropriate host dir if local storage is used).

By default the JVM is started with options `-server -Xmx1024m`.
You can override this default using `JAVA_OPTS` environment
variable:

```bash
docker run -d --name=gitblit \
	-p 8080:8080 -p 8443:8443 \
	-p 9418:9418 -p 29418:29418 \
	-e "JAVA_OPTS=-Xmx512m" \
	sjatgutzmann/docker.centos.gitblit
```

#### enviroments 
from the Dockefile. Use -e "ENVNAME value" to overwrite the defaults
##### enable internal ticket system
    ENV TICKET_SERVICE com.gitblit.tickets.BranchTicketService
##### set passfrase of this gitblit server -> generate a token to access this server
    ENV FEDERATION_PASS gitblitdefault20161223
#### properties to connect to another gitblit server
    ENV FEDERATION1_MIRROR true
    ENV FEDERATION1_BARE true
    ENV FEDERATION1_MERGE_ACCOUNTS true
    ENV FEDERATION1_URL https://dev.gitblit.com
    ENV FEDERATION1_TOKEN 6f3b8a24bf970f17289b234284c94f43eb42f0e4
    ENV FEDERATION1_TIME="120 mins"
    ENV FEDERATION1_FOLDER="gitblit"
