#!/usr/bin/perl

print "Starting Load Balancer\n";
system "/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy/haproxy.pid";
 $SIG{HUP} = sub {
    print "Reloading configuration...\n";
    system "/usr/sbin/haproxy  -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy/haproxy.pid -sf `cat /var/run/haproxy/haproxy.pid`"; #can be "system /exitpoint"
 };
my $continue = 1;
while ($continue) {
     sleep 3;
}
print "Exiting launch script"
