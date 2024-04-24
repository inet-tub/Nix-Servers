#!/bin/sh -e

# This is stage 2, the part of the initialization that is run once
# the s6 supervision tree has been set up. This is where all the
# services are brought up, and the CMD, if any, is run.

trap : INT  # guard against ^C as much as possible

prog=/run/s6/basedir/scripts/rc.init
top="$1" ; shift

if test -d /run/s6/container_environment ; then
  s6-chmod 0755 /run/s6/container_environment
fi

if v=`printcontenv S6_VERBOSITY` && eltest "$v" =~ '^[[:digit:]]+$' ; then : ; else
  v=2
fi
cv=$((v - 1))
if test "$cv" -lt 0 ; then
  cv=0
fi

if hook=`printcontenv S6_STAGE2_HOOK` && test -n "$hook" ; then
  set +e
  $hook
  r=$?
  set -e
  if eltest "$r" -gt 0 -a "$v" -gt 0 ; then
    echo "$prog: warning: hook $hook exited $r" 1>&2
  fi
fi

if profile=`printcontenv S6_RUNTIME_PROFILE` ; then
  etc="/etc/cont-profile.d/$profile"
else
  etc=/etc
fi

s6-rc-compile -v"$cv" /run/s6/db "$etc/s6-overlay/s6-rc.d" /package/admin/s6-overlay-3.1.6.2/etc/s6-rc/sources
s6-rc-init -c /run/s6/db /run/service

if timeout=`printcontenv S6_CMD_WAIT_FOR_SERVICES_MAXTIME` && eltest "$timeout" =~ '^[[:digit:]]+$' ; then : ; else
  timeout=5000
fi

set +e
s6-rc -v$v -u -t "$timeout" -- change "$top"
r=$?
set -e

if b=`printcontenv S6_BEHAVIOUR_IF_STAGE2_FAILS` && eltest "$r" -gt 0 -a "$b" =~ '^[[:digit:]]+$' -a "$b" -gt 0 ; then
  echo "$prog: warning: s6-rc failed to properly bring all the services up! Check your logs (in /run/uncaught-logs/current if you have in-container logging) for more information." 1>&2
  if test "$b" -ge 2 ; then
    echo "$prog: fatal: stopping the container." 1>&2
    echo "$r" > /run/s6-linux-init-container-results/exitcode
    exec /run/s6/basedir/bin/halt
  fi
fi

if test "$#" -gt 0 ; then
  cd `s6-cat < /run/s6/workdir`
  set +e
  arg0=`printcontenv S6_CMD_ARG0`
  if b=`printcontenv S6_CMD_USE_TERMINAL` && eltest "$b" =~ '^[[:digit:]]+$' -a "$b" -gt 0 && b=`tty` ; then
    arg0="redirfd -w 1 $b fdmove -c 2 1 $arg0"
  fi
  if b=`printcontenv S6_CMD_RECEIVE_SIGNALS` && eltest "$b" =~ '^[[:digit:]]+$' -a "$b" -gt 0 ; then
    $arg0 "$@" &
    cmdpid="$!"
    echo "$cmdpid" > /run/s6/cmdpid
    wait "$cmdpid"
    r="$?"
    rm -f /run/s6/cmdpid
  else
    $arg0 "$@"
    r="$?"
  fi
  set -e
  echo "$r" > /run/s6-linux-init-container-results/exitcode
  exec /run/s6/basedir/bin/halt
fi