#!bin/bash
set -e
for filePath in $1/*.yml; do
    fileName="$(expr $filePath \: '/etc/prometheus/\(.*\)')"
    if [ ! "$fileName" == "/prometheus.yml" ]; then
        err="$(promtool check rules $filePath | grep -c SUCCESS)"
    fi
done