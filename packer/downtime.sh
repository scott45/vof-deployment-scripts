#!/bin/bash
x=$(curl -I vof-url 2>/dev/null | head -n 1 | cut -d$' ' -f2)
if [[ $x == 502 ]]; then
  cpu_load=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
  memory_load=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
  limit=70
  # roundoff cpu load to 3 decimal places
  cpu_load=$(printf "%.3f\n" $(echo $cpu_load | bc -l))
  if (( $(awk 'BEGIN {print ("'$cpu_load'" >= "'$limit'")}') )); then
    message="Instance has a memory leak, CPU load is greater than 70% on "$(hostname)
    source /home/vof/.env_setup_rc; curl -X POST --data-urlencode "payload={\"channel\": \"$(echo $SLACK_CHANNEL)\", \"username\": \"loadbalancer\", \"text\": \"$message\", \"icon_emoji\": \":obama-sad:\"}" $(echo $SLACK_WEBHOOK)
  fi
  if (( $(awk 'BEGIN {print ("'$memory_load'" >= "'$limit'")}') )); then
    message="Instance has a memory leak, Memory load is greater than 70% on "$(hostname)
    source /home/vof/.env_setup_rc; curl -X POST --data-urlencode "payload={\"channel\": \"$(echo $SLACK_CHANNEL)\", \"username\": \"loadbalancer\", \"text\": \"$message\", \"icon_emoji\": \":obama-sad:\"}" $(echo $SLACK_WEBHOOK)
  fi
  message="vof downtime: Failing healthchecks on "$(hostname)
  source /home/vof/.env_setup_rc; curl -X POST --data-urlencode "payload={\"channel\": \"$(echo $SLACK_CHANNEL)\", \"username\": \"loadbalancer\", \"text\": \"$message\", \"icon_emoji\": \":obama-sad:\"}" $(echo $SLACK_WEBHOOK)
fi