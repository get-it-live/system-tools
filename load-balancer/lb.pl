#!/usr/bin/perl

print "Starting Load Balancer\n";
system "/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy/haproxy.pid";
 $SIG{HUP} = sub {
    system "/usr/sbin/haproxy  -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy/haproxy.pid -sf $(cat ${PIDFILE})"; #can be "system /exitpoint"
    die "Exiting\n"
};

print "Exiting launch script"
