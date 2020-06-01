#!/bin/bash
set -e

cd $(dirname $0)

apt update 
apt install -y jq

curl -XDELETE http://mailhog:8025/api/v1/messages
sleep 1
python test.py
sleep 1
RET=$(curl http://mailhog:8025/api/v2/messages | jq .count)
if [ "$RET" == "1" ]; then
  echo "success"
  exit 0
else
  echo "Failuer: $RET"
  exit 1
fi

