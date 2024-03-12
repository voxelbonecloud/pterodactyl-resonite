FROM	debian:bookworm	

LABEL 	author="bredo" maintainer="bredo@voxelbone.cloud"

RUN 	apt update && apt upgrade -y \
	&& dpkg --add-architecture i386\
	&& apt install -y apt-transport-https dirmngr gnupg ca-certificates iproute2 unzip sqlite3 fontconfig lib32gcc-s1 curl \
 	&& curl -SslL -o /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
  	&& yes | dpkg -i /tmp/packages-microsoft-prod.deb \
	&& apt update \
	&& apt install -y mono-complete dotnet-sdk-8.0 \ 
	&& useradd -m -d /home/container -s /bin/bash container

USER 	container
ENV 	USER=container HOME=/home/container
ENV 	DEBIAN_FRONTEND noninteractive

WORKDIR	/home/container

COPY 	./entrypoint.sh /entrypoint.sh
CMD 	[ "/bin/bash", "/entrypoint.sh" ]
