#!/bin/zsh

TOKEN=""
DEVICE_ID=""

CAPABILITY="devices.capabilities.on_off"
INSTANCE="on"

CURRENT_VALUE=$(
  curl -sS \
    -H "Authorization: Bearer $TOKEN" \
    "https://api.iot.yandex.net/v1.0/devices/$DEVICE_ID" \
  | /usr/bin/python3 -c '
import json, sys
data = json.load(sys.stdin)
for cap in data.get("capabilities", []):
    if cap.get("type") == "devices.capabilities.on_off":
        state = cap.get("state", {})
        if state.get("instance") == "on":
            print("true" if state.get("value") else "false")
            break
'
)

if [ "$CURRENT_VALUE" = "true" ]; then
  NEW_VALUE=false
else
  NEW_VALUE=true
fi

curl -sS -X POST "https://api.iot.yandex.net/v1.0/devices/actions" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  --data "{
    \"devices\": [
      {
        \"id\": \"$DEVICE_ID\",
        \"actions\": [
          {
            \"type\": \"$CAPABILITY\",
            \"state\": {
              \"instance\": \"$INSTANCE\",
              \"value\": $NEW_VALUE
            }
          }
        ]
      }
    ]
  }"