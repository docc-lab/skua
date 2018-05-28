#!/bin/bash
set -x
lttng stop
sleep 2
lttng destroy
sleep 3
killall babeltrace
sleep 0.1

