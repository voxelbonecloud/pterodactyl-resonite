FROM	mcr.microsoft.com/dotnet/runtime:8.0-bookworm-slim

LABEL 	author="Voxel Bone Cloud" maintainer="github@voxelbone.cloud"

RUN 	apt update \
	&& dpkg --add-architecture i386 \
	&& apt install lib32gcc-s1 libfreetype6 -y \
	&& useradd -m -d /home/container -s /bin/bash container

USER 	container
ENV 	USER=container HOME=/home/container
ENV 	DEBIAN_FRONTEND noninteractive

WORKDIR	/home/container

COPY 	./entrypoint.sh /entrypoint.sh
CMD 	[ "/bin/bash", "/entrypoint.sh" ]
