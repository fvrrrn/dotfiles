#!/bin/sh

while true; do
    VOL_INFO=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}')
    MUTE_INFO=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    if [ "$MUTE_INFO" = "yes" ]; then
        VOLUME="V: muted ($VOL_INFO)"
    else
        VOLUME="V: $VOL_INFO"
    fi

    # TODO: 
    SINK_NAME=$(pactl get-default-sink)
    if [ -n "$SINK_NAME" ]; then
        OUTPUT=$(pactl list sinks | grep -A 20 "Name: $SINK_NAME" | grep 'Description:' | sed 's/^[ \t]*Description: //')
    else
        OUTPUT="Unknown output"
    fi

    WIFI_STATE=$(nmcli -t -f WIFI g)
    if [ "$WIFI_STATE" = "enabled" ]; then
        SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)
        STRENGTH=$(nmcli -t -f ACTIVE,SIGNAL dev wifi | grep '^yes' | cut -d: -f2)
        WIFI="W: $STRENGTH%"
    else
        WIFI="W: down"
    fi

    if command -v acpi >/dev/null 2>&1; then
        BATTERY=$(acpi -b | sed 's/Battery 0: //')
    elif [ -d /sys/class/power_supply/BAT0 ]; then
        CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)
        STATUS=$(cat /sys/class/power_supply/BAT0/status)
        BATTERY="$STATUS $CAPACITY%"
    else
        BATTERY="No battery"
    fi

    # Time
    TIME=$(date '+%Y-%m-%d %H:%M')

    echo "$VOLUME | $WIFI | $BATTERY | $TIME"
    sleep 5
done
