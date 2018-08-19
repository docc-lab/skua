# Skua
Integrates LTTng's kernel-level tracing with the Jaeger trace framework. 

## Design
See [our slides](http://math.mit.edu/research/highschool/primes/materials/2018/conf/12-4%20Sheth-Sun.pdf) for details on our motivation, design, implementation, and results. 

## Requirements
- OpenTracing C++ v1.3.0
- Apache Thrift v0.11.0
- Golang with a `GOPATH` setup and `$GOPATH/bin` added to the path

## Setup
1. Recompile your Linux kernel with our [modified version of Linux](https://github.com/docc-lab/skua-linux-lttng). Because our changes to the kernel are very minimal, it is also possible to apply the [patch](https://github.com/docc-lab/skua-linux-lttng/compare/a3225b07d9437791069476cc1669f879d2cf6bb2...master.patch) to a different Linux source tree. 

2. Compile and install [the skua kernel module](https://github.com/docc-lab/skua-jaeger-ctx) using the instructions in the README. 

3. Install [lttng-tools](https://github.com/docc-lab/skua-lttng-tools/) v2.10. 

4. Install our modified version of [lttng-modules](https://github.com/docc-lab/skua-lttng-modules) v2.10. 

5. Fetch the [skua-lttng-adapter](https://github.com/docc-lab/skua-lttng-adapter) using `go get -u github.com/docc-lab/skua-lttng-adapter`. 

6. Install Skua-patched Jaeger client libraries as needed. Currently, we support [C++](https://github.com/docc-lab/skua-jaeger-client-cpp) and [Java](https://github.com/docc-lab/skua-jaeger-client-java). 

## Usage
To start tracing, run the `./start-tracing.sh` script. Then, you must track the processes that you are targetting. The easiest way to do this is by prepending the `./trace-process.sh` script before the given command. If this is not possible, you must manually track the PID of the target process using `lttng track -k --pid <pid>`. To stop tracing, run the `./stop-tracing.sh` script. 

In addition, the process being traced must be instrumented using a modified Jaeger client library, like [our `jaeger-client-cpp`](https://github.com/SkuaTracing/jaeger-client-cpp). This ensures that the context information is propagated into the kernel properly. 
