#!/bin/bash

$@ &

PROCESS_PID=$!

lttng track -k --pid $PROCESS_PID

trap "kill $PROCESS_PID" sigint
wait $PROCESS_PID

lttng untrack -k --pid $PROCESS_PID

