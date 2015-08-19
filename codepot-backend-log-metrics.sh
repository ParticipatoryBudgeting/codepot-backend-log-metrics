#!/usr/bin/env bash

error_counter() {
    errorCode=$1
    errors_total=$(grep " ${errorCode} " /var/log/nginx/backend.codepot.access.log)
    errors_today=$(echo "$errors_total" | grep `date +"%d/%b"`)
    errors_ips=$(echo "$errors_today" | cut -d ' ' -f 1 | sort -u)

    errors_counter=$(echo "$errors_today" | wc -l)
    errors_ip_counter=$(echo "$errors_ips" | wc -l)

    echo "errors-${errorCode}-total-count value=$errors_counter"
    echo "errors-${errorCode}-ip-count value=$errors_ip_counter"

    for ip in $errors_ips; do
            by_ip_counter=$(echo "$errors_total" | grep $ip | wc -l)
            echo "error-${errorCode}-by-ip-counter-$ip value=$by_ip_counter"
    done
}
data=/tmp/codepot-backend-log-metrics.txt
rm -f $data

error_counter 429 >> $data
error_counter 404 >> $data


curl -i -XPOST 'http://monitoring.codepot.tk:8086/write?db=backend' --data-binary "`cat $data`"