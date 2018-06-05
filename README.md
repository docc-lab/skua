# Skua
Integrates LTTng's kernel-level tracing with the Jaeger trace framework. 

## Design
See [our slides](http://math.mit.edu/research/highschool/primes/materials/2018/conf/12-4%20Sheth-Sun.pdf) for details on our motivation, design, implementation, and results. 

## Requirements
- Apache Thrift v0.9.2
- OpenTracing C++ v1.3.0
- Docker
- Go must be installed, and the `$GOPATH/bin` must be added to the path
- Our [modified version of Linux](https://github.com/SkuaTracing/linux-lttng) must be running

Our install of Skua uses the following layout in the home directory:
```
~
|-- golang/{src,pkg,bin}
|-- jaeger-client-cpp
|-- jaeger-client-cpp-0.3.0
|-- jaeger-ctx
|-- linux-lttng
|-- lttng-modules
|-- lttng-tools
|-- opentracing-cpp-1.3.0
|-- skua
|-- skua-tests
`-- thrift-0.9.2
```

The following steps set up Skua:
1. We assume that our modified version of Linux is already running and the above requirements are fulfilled. 
2. Build and install `lttng-modules` using the instructions in the README. 
3. Build and install `lttng-tools` using the instructions in the README. 
4. Build the `jaeger-ctx` kernel module. 
5. Build and install the `jaeger-client-cpp` and `opentracing-cpp` libraries as needed. 

## Usage
To start tracing, run the `./start-tracing.sh` script. Then, you must track the processes that you are targetting. The easiest way to do this is by prepending the `./trace-process.sh` script before the given command. If this is not possible, you must manually track the PID of the target process using `lttng track -k --pid <pid>`. To stop tracing, run the `./stop-tracing.sh` script. 

In addition, the process being traced must be instrumented using a modified Jaeger client library, like [our `jaeger-client-cpp`](https://github.com/SkuaTracing/jaeger-client-cpp). This ensures that the context information is propagated into the kernel properly. 
