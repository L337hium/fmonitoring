#!/bin/bash
#
# get_monitoring.sh v0.0.1 weimarnetz edition

# FILES
#	/etc/config/meshwizard

DEBUG=0
debug(){
	[[ $DEBUG -eq 1 ]] && echo $1
}

# https://dev.openwrt.org/browser/trunk/package/jshn/example.txt?rev=25652
. /usr/share/libubox/jshn.sh

json_init

## DATE
debug "# Getting date"
DATE=$(date "+%s")
json_add_string "date" "$DATE"

## OLSR-IP
debug "# Getting OLSR IP ADDR"
OLSR_IP=$( uci get network.wlanadhoc.ipaddr ) && json_add_string "ipaddr" "$OLSR_IP"

## OLSR-Hostname
debug "# Getting hostname"
OLSR_HOSTNAME=$( uci get meshwizard.system.hostname ) && json_add_string "hostname" "$OLSR_HOSTNAME"

## GPS
debug "# Getting GPS and location"
json_add_object "gps"
LATITUDE=$( uci get meshwizard.system.latitude ) && json_add_string "latitude" "$LATITUDE"
LONGITUDE=$( uci get meshwizard.system.longitude ) && json_add_string "longitude" "$LONGITUDE"
LOCATION=$( uci get meshwizard.system.location ) && json_add_string "location" "$LOCATION"
json_close_object

## Hardware
debug "# Getting hardware"
HARDWARE=$( cat /etc/HARDWARE ) && json_add_string "HARDWARE" "$HARDWARE"

## Firmware-Version - OpenWRT, Freifunk, ...
debug "# Getting firmware version"
OPENWRT_VERSION=$( cat /etc/openwrt_version ) && json_add_string "OPENWRT_VERSION" "$OPENWRT_VERSION"

## UPTIME
debug "# Getting uptime"
UPTIME=$( uptime | sed "s/.*up \([0-9:]*\).*/\1/" ) && json_add_string "uptime" "$UPTIME"

## CPU-Load
debug "# Getting cpu load"
CPU_LOAD=$( uptime | sed "s/.*load average: \([0-9\.]*\)/\1/" ) && json_add_string "cpu-load" "$CPU_LOAD"

## Memory # FIXME - this looks shity
debug "# Getting memory stats"
# cat /proc/meminfo
# cat /proc/meminfo | grep MemTotal | tr -s [\ ] \\t | cut -f 2

MEM_TOTAL=$( cat /proc/meminfo | grep MemTotal | tr -s [\ ] \\t | cut -f 2 ) && json_add_int "mem-total" "$MEM_TOTAL"
MEM_FREE=$( cat /proc/meminfo | grep MemFree | tr -s [\ ] \\t | cut -f 2 ) && json_add_int "mem-free" "$MEM_FREE"

## Number LAN-Clients
## Number WLAN-Clients
#ubus -vS call hostapd.wlan0 get_clients

## Devise status and statistics
debug "# Getting network device statistics"

. get_network_monitoring.sh
NETWORK_DEVICES="wan lan wlan wlanadhoc"

for DEV in $NETWORK_DEVICES; do
	DEV_STATS=$( get_network_monitoring $DEV )
	json_add_object "$DEV"

	i=$(expr 0)
	for val in $DEV_STATS; do
		case "$i" in
			"0") json_add_string "macaddr" "$val" ;;
			"1") json_add_int "up" "$val" ;;
			"2") json_add_int "link" "$val" ;;
			"3") json_add_int "rx_bytes" "$val" ;;
			"4") json_add_int "rx_packets" "$val" ;;
			"5") json_add_int "tx_bytes" "$val" ;;
			"6") json_add_int "tx_packets" "$val" ;;
		esac
		i=$(expr $i + 1)
	done
	json_close_object
done

MSG=$( json_dump )

echo $MSG


# This the server as the do

# Is node a gateway, how many user (also from neighour nodes) are using the gateways bandwidth?

# Estimate traffic over time



# monitoring server should annouce his service
# monitoring client sgould choose from service list
# client cron job should execute every 10 minutes and send data to monitoring server
