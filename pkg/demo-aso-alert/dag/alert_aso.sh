#!/bin/bash

echo "start at $(date '+%Y-%m-%d %H:%M:%S')"
tree
cd alert
/home/dolphinscheduler/.pyenv/versions/alert/bin/python alert_aso.py -d personal -P daily
echo "end at $(date '+%Y-%m-%d %H:%M:%S')"

