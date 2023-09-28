FROM	debian:bookworm	

LABEL 	author="bredo" maintainer="bredo@voxelbone.cloud"

RUN 	apt update && apt upgrade -y \
	&& dpkg --add-architecture i386\
	&& apt install -y apt-transport-https dirmngr gnupg ca-certificates iproute2 unzip sqlite3 fontconfig lib32gcc-s1 curl \
	&& export GNUPGHOME=$(mktemp -d)\
	&& gpg --recv-keys --no-default-keyring --keyring /etc/apt/trusted.gpg.d/mono-keyring.gpg --keyserver keyserver.ubuntu.com 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
	&& echo "deb [signed-by=/etc/apt/trusted.gpg.d/mono-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" > /etc/apt/sources.list.d/mono-official-stable.list \
	&& apt update \
	&& apt install -y mono-complete \ 
	&& useradd -m -d /home/container -s /bin/bash container

USER 	container
ENV 	USER=container HOME=/home/container
ENV 	DEBIAN_FRONTEND noninteractive

WORKDIR	/home/container

COPY 	./entrypoint.sh /entrypoint.sh
CMD 	[ "/bin/bash", "/entrypoint.sh" ]
