FROM ubuntu-upstart:trusty
MAINTAINER Getitlive - admin@getitlive.io

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CFFB779AADC995E4F350A060505D97A41C61B9CD
RUN grep "haproxy-1.5" /etc/apt/sources.list || echo "deb http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install haproxy
ADD lb.sh /
RUN chmod 755 /lb.sh
CMD ["/lb.sh", "-d"]
