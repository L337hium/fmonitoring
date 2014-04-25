get_network_monitoring(){
# $1 = wan | lan | wlan | wlanadhoc
	DEV=$1
	
	local TMP=$( devstatus $( uci get network.$DEV.ifname ) )
	json_load "$TMP"
	
	json_get_var MACADDR macaddr
	json_get_var UP up
	json_get_var LINK link

	json_select statistics
	
	if [[ "$DEV" == "wlan" -o "$DEV" == "wlanadhoc" ]]; then
		RX_BYTES=$( ifconfig $(uci get network.$DEV.ifname) | grep "RX bytes" | sed 's/.*RX bytes:\([0-9]*\).*/\1/' )
		RX_PACKETS=$( ifconfig $(uci get network.$DEV.ifname) | grep "RX packets" | sed 's/.*RX packets:\([0-9]*\).*/\1/' )
	
		TX_BYTES=$( ifconfig $(uci get network.$DEV.ifname) | grep "TX bytes" | sed 's/.*TX bytes:\([0-9]*\).*/\1/' )
		TX_PACKETS=$( ifconfig $(uci get network.$DEV.ifname) | grep "TX packets" | sed 's/.*TX packets:\([0-9]*\).*/\1/' )
	else
		json_get_var RX_BYTES rx_bytes
		json_get_var RX_PACKETS rx_packets
		json_get_var TX_BYTES tx_bytes
		json_get_var TX_PACKETS tx_packets
	fi
	
	unset $TMP
	
	echo "$MACADDR $UP $LINK $RX_BYTES $RX_PACKETS $TX_BYTES $TX_PACKETS"
}
