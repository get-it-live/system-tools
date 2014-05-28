FROM ubuntu:trusty

MAINTAINER Get!tLive.io

RUN echo deb http://archive.ubuntu.com/ubuntu trusty universe > /etc/apt/sources.list.d/universe.list

# we're going to want this bad boy installed so we can connect :)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq ssh
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install dnsmasq

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

# we can has SSH
EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/usr/bin/dnsmasq"]

