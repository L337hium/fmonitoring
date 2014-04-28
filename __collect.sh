#!/bin/bash
set -x

DIR=$( dirname $0 )
DB="$DIR/nodes.db"


while read -r IP
do
	[[ ! -d "$DIR/$IP" ]] && mkdir "$DIR/$IP"
	DATE=$( date "+%s" )
	ssh -nqt root@$IP "sh /usr/share/fmonitoring/get_monitoring.sh" > "$DIR/$IP/$DATE.json"
done < $DB
