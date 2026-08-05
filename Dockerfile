FROM	debian:trixie-slim

LABEL 	author="Voxel Bone Cloud" maintainer="github@voxelbone.cloud"

RUN 	apt update \
	&& apt install curl -y \
	&& curl https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb -o /tmp/packages-microsoft-prod.deb \
	&& dpkg -i /tmp/packages-microsoft-prod.deb \
	&& rm /tmp/packages-microsoft-prod.deb \
	&& dpkg --add-architecture i386 \
	&& apt update \
	&& apt install lib32gcc-s1 libfreetype6 dotnet-runtime-10.0 libmsquic -y \
	&& rm -r /var/lib/apt/lists/* \
	&& useradd -m -d /home/container -s /bin/bash container

USER 	container
ENV 	USER=container HOME=/home/container
ENV 	DEBIAN_FRONTEND noninteractive

WORKDIR	/home/container

COPY 	./entrypoint.sh /entrypoint.sh
CMD 	[ "/bin/bash", "/entrypoint.sh" ]
