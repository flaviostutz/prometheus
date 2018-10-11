# Prometheus
Prometheus server with configurable settings through ENV parameters.

By using this image you would avoid creating prometheus.yml manually, so that you indicate in ENV parameters the scrape targets and this container will start already configured to scrape them.

If you need more advanced Prometheus usage (custom alerting or more configurations), the best way is to create another container with those configurations embedded into it.

## Usage

docker-compose.yml

```
version: '3.5'

services:

  prometheus:
    image: flaviostutz/prometheus
    ports:
      - 9090:9090
    environment:
      - SCRAPE_INTERVAL=15s
      - SCRAPE_TIMEOUT=10s
      - STATIC_SCRAPE_TARGETS=mynginx1@nginx1ip:8080 mysqlexporter1@sqlexporter1ip:7070
      - DNS_SCRAPE_TARGETS=dnsscrape11@dnsscrape1:1111
```

## ENVs

- SCRAPE_INTERVAL: global time between scrappings
- SCRAPE_TIMEOUT: time after which the scraped target will be considered 'down'
- STATIC_SCRAPE_TARGETS: space separated list of "[name]@[host]:[port]</[metrics_path]>"
  - Prometheus will try to get metrics from http://[host]:[port]/metrics. 
  - [name] will be used to label all metrics gotten from this target
  - optionally, one can explicitly define the path to the metrics api via [metrics_path]
- DNS_SCRAPE_TARGETS: space separated list of "[name]@[record-name]:[port]</[metrics_path]>"
  - Prometheus will query DNS server for a type 'A' entry with name [record-name] and then try to get metrics from each returned IP at http://[found-ip]:[port]/metrics. 
  - [name] will be used to label all metrics gotten from this target
  - optionally, one can explicitly define the path to the metrics api via [metrics_path]
