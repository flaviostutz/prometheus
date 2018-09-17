#!/bin/bash

#WARNING: This code has ugly implementations because Prometheus base image doesn't have bash, just sh!

echo "Generating prometheus.yml according to ENV variables..."
FILE=/etc/prometheus/prometheus.yml

#global
cat > $FILE <<- EOM
global:
  scrape_interval: $SCRAPE_INTERVAL
  evaluation_interval: $EVALUATION_INTERVAL
  scrape_timeout: $SCRAPE_TIMEOUT

EOM


#alert managers
if [ "$ALERTMANAGER_TARGETS" != "" ]; then
    cat >> $FILE <<- EOM
alerting:
  alertmanagers:
  - static_configs:
    - targets:
EOM
    #add each alert manager target
    for i in $(echo $ALERTMANAGER_TARGETS | tr " " "\n")
    do
    cat >> $FILE <<- EOM
      - $i
EOM
    done
fi


if [ "$ALERTMANAGER_TARGETS" != "" ] || [ "$STATIC_SCRAPE_TARGETS" != "" ]; then
    cat >> $FILE <<- EOM
scrape_configs:
EOM
fi

#static scrapers
if [ "$STATIC_SCRAPE_TARGETS" != "" ]; then
    #add each static scrape target
    for SL in $(echo $STATIC_SCRAPE_TARGETS | tr " " "\n")
    do
        #this has to be done this ugly way because we don't have bash here, just sh!
        NAME=''
        HOST=''
        i=0
        for ST in $(echo $SL | tr "@" "\n")
        do
          if [ $i -eq 0 ]; then
            NAME=$ST
            i=1
          else
            HOST=$ST
          fi
        done
        cat >> $FILE <<- EOM
  - job_name: '$NAME'
    static_configs:
    - targets: ['$HOST']
EOM
    done
fi


#static scrapers
if [ "$DNS_SCRAPE_TARGETS" != "" ]; then
    #add each static scrape target
    for SL in $(echo $DNS_SCRAPE_TARGETS | tr " " "\n")
    do
        #this has to be done this ugly way because we don't have bash here, just sh!
        NAME=''
        HOST=''
        i=0
        for ST in $(echo $SL | tr "@" "\n")
        do
          if [ $i -eq 0 ]; then
            NAME=$ST
            i=1
          else
            HOST=$ST
          fi
        done
        cat >> $FILE <<- EOM
  - job_name: '$NAME'
    dns_sd_configs:
    - names: ['$HOST']
EOM
    done
fi

echo "==prometheus.yml=="
cat $FILE
echo "=================="

echo "Starting Prometheus..."

/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --web.console.libraries=/usr/share/prometheus/console_libraries \
    --web.console.templates=/usr/share/prometheus/consoles


