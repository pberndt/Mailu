#!/bin/bash
set -euxo pipefail

# Bootstrap the database if clamav is running for the first time
if [ ! -f "/data/main.cvd" ]; then
    echo "Starting primary virus DB download"
    freshclam
fi

# Run the update daemon
echo "Starting the update daemon"
freshclam -c 6 &
freshclampid=$!

# Run clamav
echo "Starting clamav"
clamd &
clamdpid=$!

# Ignore errors from here
set +euo pipefail

term=
trap 'trap "" SIGINT SIGTERM; echo "Caught signal"; term=true; killall sleep' SIGINT SIGTERM

# Monitoring loop
rc=
while [ -z "$term" ]; do
  if [ ! -d /proc/$freshclampid ]; then
    wait $freshclampid
    rc=$?
    echo "freshclam exited with code $rc"
    break
  fi
  if [ ! -d /proc/$clamdpid ]; then
    wait $clamdpid
    rc=$?
    echo "clamd exited with code $rc"
    break
  fi
  sleep 60 &
  wait $!
done

# Fix rc
if [ -n "$term" ]; then
  rc=0
else
  # Even if the process exited with 0 this is not okay
  if [ "$rc" -eq 0 ]; then
    rc=1
  fi
fi

echo "Shutting down..."
kill $freshclampid $clamdpid 2>/dev/null

for (( patience=8; patience>0; --patience )); do
  sleep 1
  if ! [ -d /proc/$freshclampid -o -d /proc/$clamdpid ]; then
    break;
  fi
done

kill -9 $freshclampid $clamdpid 2>/dev/null

exit $rc

