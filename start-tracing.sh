#!/bin/bash
set -x

# jaeger-ctx module
(
	cd ~/jaeger-ctx
	insmod jaeger_ctx.ko
)

# docker
docker stop jaeger_all_in_one
docker rm jaeger_all_in_one
docker run -d -e \
	COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
	-p 5775:5775/udp \
	-p 6831:6831/udp \
	-p 6832:6832/udp \
	-p 5778:5778 \
	-p 16686:16686 \
	-p 14268:14268 \
	-p 9411:9411 \
	--name jaeger_all_in_one \
	jaegertracing/all-in-one:latest
sleep 4

# relayd started automatically
lttng create my-kernel-session --live
lttng enable-event --kernel --all #--syscall
lttng add-context --kernel --type=pid --type=tid
lttng start
lttng untrack -k --pid --all

# start lttng-adapter
sleep 1
(
source ~/.bashrc
go get github.com/SkuaTracing/lttng-adapter
babeltrace --input-format=lttng-live net://localhost/host/voxel/my-kernel-session --clock-date --clock-gmt --no-delta | lttng-adapter
)

