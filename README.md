# Skua
Integrates LTTng's kernel-level tracing with the Jaeger trace framework. 

Note that this repository simply contains a few helper scripts to run Skua. All of the Skua repos are available [on GitHub](https://github.com/docc-lab?q=skua); see [setup](#setup) for instructions. 

## Design
See [our slides](http://math.mit.edu/research/highschool/primes/materials/2018/conf/12-4%20Sheth-Sun.pdf) for details on our motivation, design, implementation, and results. 

## Requirements
- OpenTracing C++ v1.3.0
- Apache Thrift v0.11.0
- Golang with a `$GOPATH` setup and `$GOPATH/bin` added to the path
- A working Jaeger collection setup. For development purposes, it is easiest to run the `jaegertracing/all-in-one` docker container. 
- [Babeltrace](http://diamon.org/babeltrace/)

## Setup
1. Recompile your Linux kernel with our [modified version of Linux](https://github.com/docc-lab/skua-linux-lttng). Because our changes to the kernel are very minimal, it is also possible to apply the [patch](https://github.com/docc-lab/skua-linux-lttng/compare/a3225b07d9437791069476cc1669f879d2cf6bb2...master.patch) to a different Linux source tree. 
2. Compile and install [the skua kernel module](https://github.com/docc-lab/skua-jaeger-ctx) using the instructions in the README. 
3. Install [lttng-tools](https://github.com/docc-lab/skua-lttng-tools/) v2.10. 
4. Install our modified version of [lttng-modules](https://github.com/docc-lab/skua-lttng-modules) v2.10. 
5. Fetch the [skua-lttng-adapter](https://github.com/docc-lab/skua-lttng-adapter) using `go get -u github.com/docc-lab/skua-lttng-adapter`. 
6. Install Skua-patched Jaeger client libraries as needed. Currently, have patched the [C++](https://github.com/docc-lab/skua-jaeger-client-cpp) and [Java](https://github.com/docc-lab/skua-jaeger-client-java) Jaeger clients. 

## Usage

### Instrumenting an Application
You can instrument an application using [Jaeger](https://www.jaegertracing.io/). When building your application, simply use our modified Jaeger client libraries. As of now, we only support C++ and Java -- see the setup section for links. 

### Tracing
We have included a few scripts to help streamline the tracing process. These scripts assume a working Skua setup, as detailed above, and additionally use the `jaegertracing/all-in-one` docker image for reporting traces. 

1. Start tracing by running the `./start-tracing.sh` script. 
2. Track the target process(es). Note that Skua can only trace applications that are using the modified Jaeger client libraries. The easiest way to track the target process is by prepending the `./trace-process.sh` script before the application's start command. If this is not possible, you must manually track the PID of the target process using `lttng track -k --pid <pid>`. 
3. When finished tracing, run the `./stop-tracing.sh` script. 
4. View the trace information using the Jaeger Web UI, which usually runs on port 16686. 
