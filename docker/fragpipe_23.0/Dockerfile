FROM fcyucn/fragpipe:23.0
LABEL authors="preskaa"

## add diann
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    libgomp1


RUN wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.1.0-Academia-Linux.zip && \
    unzip DIA-NN-2.1.0-Academia-Linux.zip

RUN chmod +x /fragpipe_bin/diann-2.1.0/diann-linux
#
RUN ln -s /fragpipe_bin/diann-2.1.0/diann-linux /usr/bin/diann