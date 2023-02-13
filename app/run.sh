#!/bin/bash
echo "php start"

busybox httpd -f -h /opt/www
