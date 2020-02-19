#!/bin/bash
set -x
sudo lttng stop
sleep 2
sudo lttng destroy
sleep 3
killall babeltrace
sleep 0.1

