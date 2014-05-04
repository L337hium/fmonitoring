#!/bin/sh
# $1 = wan | lan | wlan | wlanadhoc
[[ -z $1 ]] && exit 1

IFNAME=$1

get_device(){
	. /usr/share/libubox/jshn.sh
	json_load "$( ifstatus $1 )"
	json_get_var DEVICE device
	echo $DEVICE
}

get_devstatus(){
	. /usr/share/libubox/jshn.sh
	json_load "$( devstatus $( get_device $1 ) )"
	echo $( json_dump )
}

build_json(){
	. /usr/share/libubox/jshn.sh
	json_init
	json_add_string "ifname" "$IFNAME"
	json_add_string "device" "$( get_device $IFNAME )"
	json_add_string "macaddr" "$MACADDR"
	json_add_int "up" "$UP"
	json_add_int "link" "$LINK"
	json_add_int "rx_bytes" "$RX_BYTES"
	json_add_int "rx_packets" "$RX_PACKETS"
	json_add_int "tx_bytes" "$TX_BYTES"
	json_add_int "tx_packets" "$TX_PACKETS"
	echo $( json_dump )
}

. /usr/share/libubox/jshn.sh
json_load "$( get_devstatus $IFNAME )"
json_get_var MACADDR macaddr
json_get_var UP up
json_get_var LINK link
json_select statistics
json_get_var RX_BYTES rx_bytes
json_get_var RX_PACKETS rx_packets
json_get_var TX_BYTES tx_bytes
json_get_var TX_PACKETS tx_packets

build_json
exit 0
