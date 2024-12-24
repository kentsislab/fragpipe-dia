FROM fcyucn/fragpipe:22.0
LABEL authors="preskaa"

## add diann
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    libgomp1


RUN wget https://github.com/vdemichev/DiaNN/releases/download/1.9.1/diann-1.9.1.Linux.zip && \
    unzip diann-1.9.1.Linux.zip

RUN chmod +x /fragpipe_bin/diann-1.9.1/diann-linux
#
RUN ln -s /fragpipe_bin/diann-1.9.1/diann-linux /usr/bin/diann

#### download licensed tools that can't be packaged into docker image here:
# https://github.com/shahcompbio/fragpipe-smk/releases/download/v0.0.1-beta/fragpipe_config_tools.tar.gz

# Copy local fragpipe_config_tools.tar.gz into the Docker image
COPY fragpipe_config_tools.tar.gz /fragpipe_bin/

# Extract the tar.gz file
RUN tar -xzvf /fragpipe_bin/fragpipe_config_tools.tar.gz -C /fragpipe_bin/

# install easypqp
RUN pip install git+https://github.com/grosenberger/easypqp.git@master