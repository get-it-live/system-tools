#!/bin/sh

# Manage Haproxy in foreground mode 
# Handle 'graceful' reload when container receives a HUP signal
PIDFILE="/var/run/haproxy.pid"
haproxy="/usr/sbin/haproxy -db -f /etc/haproxy/haproxy.cfg -p ${PIDFILE}"

sigquit()
{
   echo "signal QUIT received"
   exit 0
}

sigint()
{
   echo "signal INT received, script ending"
   exit 0
}

sighup()
{
  echo "HUP signal received, gracefully reloading Load Balancer..."
  ${haproxy} -sf $(cat $PIDFILE)
}

trap 'sigquit' QUIT
trap 'sigint'  INT
trap 'sighup'  HUP

# Run in foreground mode
while true; do
  echo "Starting LB..."
  ${haproxy}&
  wait 1
  echo "waiting"
done
