# Skua
Integrates LTTng's kernel-level tracing with the Jaeger trace framework. 

## Requirements
- Apache Thrift v0.9.2
- OpenTracing C++ v1.3.0
- Docker
- Go must be installed, and the GOPATH/bin must be added to the path
- Our [modified version of Linux](https://github.com/SkuaTracing/linux-lttng) must be running

Our install of Skua uses the following layout in the home directory:
```
~
|-- golang
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

## Design
TODO

## Usage
TODO
