FROM ubuntu-upstart:trusty
MAINTAINER Getitlive - admin@getitlive.io

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CFFB779AADC995E4F350A060505D97A41C61B9CD
RUN grep "haproxy-1.5" /etc/apt/sources.list || echo "deb http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install haproxy
# Enable remote syslog receiving for Haproxy messages
RUN sudo sed -i 's/#$ModLoad imudp/$ModLoad imudp/' /etc/rsyslog.conf; sudo sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/' /etc/rsyslog.conf; sudo service rsyslog restart
ADD lb.pl /
RUN chmod 755 /lb.pl
ENTRYPOINT /lb.pl
