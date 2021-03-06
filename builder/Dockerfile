FROM ubuntu:trusty

MAINTAINER Get!tLive.io

#RUN grep universe /etc/apt/sources.list || echo deb http://archive.ubuntu.com/ubuntu trusty universe > /etc/apt/sources.list.d/universe.list

RUN apt-get update && apt-get install -yq curl git apparmor ssh lxc

# let's grab the lastest "master" version of the install.sh script >:)
RUN curl -sLS https://raw.github.com/dotcloud/docker/master/hack/install.sh | sh

RUN curl -sLS https://raw.github.com/dotcloud/docker/master/hack/dind -o /dind && chmod +x /dind


ADD init-lxc.conf /etc/init/fake-container-events.conf
ADD docker /etc/default/

# undo some leet hax of the base image
RUN rm /usr/sbin/policy-rc.d; \
	rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl

# generate a nice UTF-8 locale for our use
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# remove some pointless services
RUN /usr/sbin/update-rc.d -f ondemand remove; \
	( \
		cd /etc/init; \
		for f in \
			u*.conf \
			tty[2-9].conf \
			plymouth*.conf \
			hwclock*.conf \
			module*.conf\
		; do \
			mv $f $f.orig; \
		done \
	); \
	echo '# /lib/init/fstab: cleared out for bare-bones lxc' > /lib/init/fstab

# small fix for SSH in 13.10 (that's harmless everywhere else)
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd
# Allow SSH for root user with password auth.
RUN sed -ri 's/^PermitRootLogin\s+without-password$/PermitRootLogin yes/' /etc/ssh/sshd_config; echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config
# First password if debug needed before it gets re-changed automatically to sthg more 'secret'.
RUN echo 'root:docker.io' | chpasswd

# Install git, add 'git' user
RUN /usr/sbin/useradd -d /git -m -s /usr/bin/git-shell git; mkdir -p /git/.ssh && chown git. /git/.ssh

# Add pubkey
RUN mkdir -p /git/.ssh/
ADD getitlive.pubkey /git/.ssh/authorized_keys
ADD ssh-git.sh /git/ssh-git.sh
ADD build.sh /git/build.sh
RUN chmod 755 /git/ssh-git.sh /git/build.sh
ADD getcommits.sh /git/getcommits.sh
RUN chmod 755 /git/getcommits.sh
#VOLUME ["/var/lib/docker"]

EXPOSE 22

# prepare for takeoff
CMD ["/sbin/init"]

ENTRYPOINT ["/dind"]
