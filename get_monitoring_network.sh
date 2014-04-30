#!/bin/sh
# $1 = wan | lan | wlan | wlanadhoc
[[ -z $1 ]] && exit 1

DEV="$1"
local TMP=$( devstatus $( uci get network.$DEV.ifname ) )
[[ "$TMP" == "Usage: /sbin/devstatus <device>" ]] && exit 2

. /usr/share/libubox/jshn.sh
json_load "$TMP"
json_get_var MACADDR macaddr
json_get_var UP up
json_get_var LINK link
json_select statistics
#if [[ "$DEV" == "wlan" -o "$DEV" == "wlanadhoc" ]]; then
#	RX_BYTES=$( ifconfig $(uci get network.$DEV.ifname) | grep "RX bytes" | sed 's/.*RX bytes:\([0-9]*\).*/\1/' )
#	RX_PACKETS=$( ifconfig $(uci get network.$DEV.ifname) | grep "RX packets" | sed 's/.*RX packets:\([0-9]*\).*/\1/' )
#	TX_BYTES=$( ifconfig $(uci get network.$DEV.ifname) | grep "TX bytes" | sed 's/.*TX bytes:\([0-9]*\).*/\1/' )
#	TX_PACKETS=$( ifconfig $(uci get network.$DEV.ifname) | grep "TX packets" | sed 's/.*TX packets:\([0-9]*\).*/\1/' )
#else
	json_get_var RX_BYTES rx_bytes
	json_get_var RX_PACKETS rx_packets
	json_get_var TX_BYTES tx_bytes
	json_get_var TX_PACKETS tx_packets
#fi
unset $TMP

build_json(){
	. /usr/share/libubox/jshn.sh
	json_init
	json_add_string "macaddr" "$MACADDR"
	json_add_int "up" "$UP"
	json_add_int "link" "$LINK"
	json_add_int "rx_bytes" "$RX_BYTES"
	json_add_int "rx_packets" "$RX_PACKETS"
	json_add_int "tx_bytes" "$TX_BYTES"
	json_add_int "tx_packets" "$TX_PACKETS"
	echo $(json_dump)
}

build_json
exit 0

# TODO: Use `ifstatus` ! ! !
# avoid 
