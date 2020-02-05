# Purpose: build a docker image for Julia   
# =========================================================================
# References:
# https://techytok.com/from-zero-to-julia-using-docker/
# https://github.com/aurelio-amerio/techytok-examples/blob/master/julia-docker/Dockerfile

ARG JULIA_VERSION=1.3.1

FROM julia:${JULIA_VERSION}
# Adds metadata to the image as a key value pair example LABEL version="1.0"
LABEL maintainer="Jerry Y <https://github.com/mathsrocks>"

########################################################
# Essential packages for remote debugging and login in
########################################################

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    apt-utils gcc g++ openssh-server cmake build-essential gdb gdbserver rsync vim locales 
RUN apt-get install -y bzip2 wget gnupg dirmngr apt-transport-https ca-certificates openssh-server tmux && \
    apt-get clean

# Setup ssh
RUN mkdir /var/run/sshd && \
    echo 'root:r00t_pwd' | chpasswd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    mkdir /root/.ssh

# Remove leftovers
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose 22 for ssh server. 7777 for gdb server.
EXPOSE 22 7777

# Add a user for debugging
RUN useradd -ms /bin/bash debugger
RUN echo 'debugger:de6ugger_pwd' | chpasswd

########################################################
# Add custom packages and development environment here
########################################################

########################################################

CMD ["/usr/sbin/sshd", "-D"]

# Add support for English and Italian
COPY locale.gen /etc/locale.gen
RUN locale-gen
