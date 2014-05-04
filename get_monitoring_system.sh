#!/bin/sh
. /usr/share/libubox/jshn.sh

json_init
#json_add_int "date" "$(date "+%s")"
json_add_string "hostname" "$( uci get meshwizard.system.hostname )"
json_add_string "hardware" "$( cat /etc/HARDWARE )"
json_add_string "openwrt-version" "$( cat /etc/openwrt_version )"
json_add_string "uptime" "$( cat /proc/uptime | awk '{print $1}' )"
json_add_string "cpu-load" "$( uptime | sed "s/.*load average: \([0-9\.]*\)/\1/" )"
json_add_int "mem-total" "$( cat /proc/meminfo | grep MemTotal | tr -s [\ ] \\t | cut -f 2 )"
json_add_int "mem-free" "$( cat /proc/meminfo | grep MemFree | tr -s [\ ] \\t | cut -f 2 )"

echo $(json_dump)
exit 0
