#!/bin/bash

$@ &

PROCESS_PID=$!

sudo lttng track -k --pid $PROCESS_PID

trap "kill $PROCESS_PID" sigint
wait $PROCESS_PID

sudo lttng untrack -k --pid $PROCESS_PID

