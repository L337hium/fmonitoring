#!/bin/bash

[[ -z $@ ]] && echo "No router to deploy was specified." && exit 1

DIR=$( dirname $0 )
DB="$DIR/nodes.db"

for i in $@; do
	ssh -qt root@$i "mkdir /usr/share/fmonitoring"
	scp get_monitoring.sh get_monitoring_system.sh get_monitoring_network.sh root@$i:/usr/share/fmonitoring/
	
	grep -q "$i" $DB
	if [[ $? -gt 0 ]]; then
		echo "$i" >> $DB
	fi
done

exit 0
