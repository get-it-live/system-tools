FROM ubuntu:trusty

MAINTAINER Get!tLive.io

RUN echo deb http://archive.ubuntu.com/ubuntu trusty universe > /etc/apt/sources.list.d/universe.list

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && apt-get -y install dnsmasq

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

# we can has SSH
EXPOSE 53/udp 53/tcp

# Todo : change this to a .sh script that will manage dnsmasq and 'hot-restart' it on HUP signals
ENTRYPOINT ["/usr/sbin/dnsmasq"]
CMD ["-d"]
