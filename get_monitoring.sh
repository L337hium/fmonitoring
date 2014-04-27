#!/bin/sh

if [[ -z "$*" ]]; then
	__PARAMS="system gps olsr network"
else
	__PARAMS="$*"
fi

OUT='{ "date": '$(date "+%s")
for __PARAM in $__PARAMS; do
	case $__PARAM in
		"system")	
			SYSTEM=$(sh get_monitoring_system.sh)
			OUT=$OUT', "system": '$SYSTEM
			;;
		"gps")	
			. /usr/share/libubox/jshn.sh
			json_init
			json_add_string "latitude" "$( uci get meshwizard.system.latitude )"
			json_add_string "longitude" "$( uci get meshwizard.system.longitude )"
			json_add_string "location" "$( uci get meshwizard.system.location )"
			OUT=$OUT', "gps": '$( json_dump )
			;;
		"olsr")	
			OUT=$OUT', "olsr": { '
			OUT=$OUT'"ip": "'$( uci get network.wlanadhoc.ipaddr )'", '
			OUT=$OUT'"hostname": "'$( uci get meshwizard.system.hostname )'", '
			OUT=$OUT'"neighbors": '$( echo /links | nc localhost 9090 )
			OUT=$OUT' }'
			;;
		"network")
			#ubus -vS call hostapd.wlan0 get_clients
			NETWORK_DEVICES="wan lan wlan wlanadhoc"

			OUT=$OUT', "network": { '
			local j=0
			for DEV in $NETWORK_DEVICES; do
				NET_STATS=$( sh get_monitoring_network.sh $DEV )
				[[ $j -gt 0 ]] && OUT=$OUT", "
				OUT=$OUT' "'$DEV'": '$NET_STATS
				j=$( expr $j + 1 )
			done
			OUT=$OUT' }'
			;;
		*)
			;;
	esac
done
OUT=$OUT' }'

echo $OUT
exit 0
