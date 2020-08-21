# container_devpi
An offline Devpi server and Devpi web interface in a container to store Python packages in on-site indexes

**Build the container**
Use the Dockerfile to build the container. The "Docker-entrypoint.sh" file will be pulled into the build.

**Run the container**
Use the Docker-Compose.yml file to stand up the container with docker-compose.

**Access the web interface**
http://localhost:3141/

**Uploading python packages files**

Upload downloaded PIP files - ensure the perms are set to 755 on all pip packages - otherwise you get an error:
`....whl: does not contain PKGINFO, skipping`
Do this from bash cli on a server with local devpi-client installed:
`pip install devpi-client`
OR 
SSH onto your docker host and copy the pip packages to /data/devpi/pip-packages directory.
the directory /data/devpi/ is bind mounted into the container on run time - so the packages will be copied in.
Run this devpi container and jump into the running container bash shell using:
`docker exec -it <devpi-server container name> /bin/bash`
Once inside, you need to index the pip packages - run these commands to index the files:

```
devpi use http://localhost:3141/root/public --set-cfg
devpi login root --password=$DEVPI_PASSWORD
devpi upload --from-dir --formats=* ./pip-packages
```
Note: Run "ls" to see which directory you are in - pip-packages can be replaced with which ever directory you copied the files into on the host.

**Pulling packages from Devpi server**
You need to tell the pip install line that you want to use the local devpi server as the source for the package, and that the devpi server is a trusted repo.

```
$ pip install <pip package name>==<pip package version> -i http://localhost:3141/root/public --trusted-host localhost
```

**Use this container in build to host pip packages**

Run the devpi container on the host where builds will be created;
To use this devpi cache to speed up your dockerfile builds, add the code below in your dockerfiles. 
This will add the devpi container as an optional cache for pip. 
The docker containers will try using port 3141 on the docker host first and fall back on the normal pypi servers without breaking the build.

```
# Install netcat for ip route
RUN apt-get update \
 && apt-get install -y netcat \
 && rm -rf /var/lib/apt/lists/*

 # Use the optional devpi pip cache to speed development
RUN export HOST_IP=$(ip route| awk '/^default/ {print $3}') \
 && mkdir -p ~/.pip \
 && echo [global] >> ~/.pip/pip.conf \
 && echo extra-index-url = http://$HOST_IP:3141/app/dev/+simple >> ~/.pip/pip.conf \
 && echo [install] >> ~/.pip/pip.conf \
 && echo trusted-host = $HOST_IP >> ~/.pip/pip.conf \
 && cat ~/.pip/pip.conf
```
