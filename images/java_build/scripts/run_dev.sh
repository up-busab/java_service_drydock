#!/bin/sh
#ls -la 

if [[ -z "${DELAY_STARTUP}" ]]; then
  echo "Starting application"
else
  DELAY=${DELAY_STARTUP}
  i=0
  while [ $i -lt $DELAY ]
  do
    sleep 5s
    echo "Delaying start..."
    true $(( i+=5 ))
  done
fi

exec /app/app

