#!/bin/bash
source ./.env
URL=https://10.67.3.2:8006/
printf "Reverting Ubuntu\n"
curl -XPOST --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/121/snapshot/base/rollback 
printf "\nReverting EndeavorOS\n"
curl -XPOST --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/122/snapshot/base/rollback 
printf "\nReverting Fedora\n"
curl -XPOST --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/139/snapshot/base/rollback 
printf "\nReverting Oracle\n"
curl -XPOST --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/140/snapshot/base/rollback 
printf "\n"

sleep 5;

status1=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/121/status/current | jq .data.status)
status2=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/122/status/current | jq .data.status) 
status3=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/139/status/current | jq .data.status)
status4=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/140/status/current | jq .data.status)
while [ "$status1" != '"running"' ] || [ "$status2" != '"running"' ] || [ "$status3" != '"running"' ] || [ "$status4" != '"running"' ]; do
  if [ "$status1" != '"running"' ];then
    status1=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/121/status/current | jq .data.status)
    printf "Vm1: $status1\n"
  fi
  if [ "$status2" != '"running"' ];then
    status2=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/122/status/current | jq .data.status) 
    printf "Vm2: $status2\n"
  fi
  if [ "$status3" != '"running"' ];then
    status3=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/139/status/current | jq .data.status) 
    printf "Vm3: $status3\n"
  fi
  if [ "$status4" != '"running"' ];then
    status4=$(curl --silent --insecure -H "Authorization: $api_token" "$URL"api2/json/nodes/vm1/qemu/140/status/current | jq .data.status) 
    printf "Vm4: $status4\n"
  fi
  if [ "$status1" = "running" ] && [ "$status2" = "running" ] && [ "$status3" = "running" ] && [ "$status4" = "running" ];then
    printf "[DONE]\n"
    exit 1;
  fi
  sleep 1;
done
printf "All vms completed reverting\n"
