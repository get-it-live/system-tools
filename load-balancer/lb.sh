#!/bin/sh

# Manage Haproxy in foreground mode
# Handle 'graceful' reload when container receives a HUP signal
# HAproxy doesn't write its PID to file when running in _foreground_ mode. 'not useful' according to a very assertive opinion from its creator.
PIDFILE="/var/run/haproxy/haproxy.pid"
haproxy="/usr/sbin/haproxy -db -f /etc/haproxy/haproxy.cfg -p ${PIDFILE}"

sigquit()
{
   echo "signal QUIT received"
   exit 0
}

sigint()
{
   echo "signal INT received, script ending"
   rm -f ${PIDFILE}
   exit 0
}

sighup()
{
  echo "HUP signal received, gracefully reloading Load Balancer..."
  ${haproxy} -sf $(cat ${PIDFILE})&
  echo $! > ${PIDFILE}
}

trap 'sigquit' QUIT
trap 'sigint'  INT
trap 'sighup'  HUP

# Run in foreground mode
echo "Starting LB..."
${haproxy}&
echo $! > ${PIDFILE}
while true; do
  wait %1
  echo "waiting"
done
