# Skua
Integrates LTTng's kernel-level tracing with the Jaeger trace framework. 

Note that this repository simply contains a few helper scripts to run Skua. All of the Skua repos are available [on GitHub](https://github.com/docc-lab?q=skua); see [setup](#setup) for instructions. 

## Design
See [our slides](https://andrewsun.com/static/skua-devconf.pdf) for details on our motivation, design, implementation, and results. 

## Requirements
- OpenTracing C++ v1.4.2
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

## Skua set up

### Environment
On Mass Open Cloud:

1. **Flavor**: m1.s2.xlarge & 50+ GB Volume (comply kernel takes space)
2. **OS**: Ubuntu 18 LTS
3. **Security Group** need to open the following ports for **Ingress** and **Egress**
	
	TCP: 5000, 5778, 9411, 14268, 16686, 22, 80, 443
	
	UDP: 5775, 6831, 6832

4. Add **SSH key** to github

```shell
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -C "your@email.com"
cat id_rsa.pub
```

Add content in **id_rsa.pub** it to [github ssh keys](https://github.com/settings/keys)

### 1. Apply patched kernel (4.15.14)
More info from: [docc-lab/skua-linux-lttng](https://github.com/docc-lab/skua-linux-lttng)

**Either use root or normal user:**

```shell
sudo apt-get update
sudo apt-get install -y git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison cmake libyaml-cpp-dev
cd
wget https://github.com/docc-lab/skua-linux-lttng/compare/a3225b07d9437791069476cc1669f879d2cf6bb2...master.patch
mv a3225b07d9437791069476cc1669f879d2cf6bb2...master.patch skua.patch
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.14.tar.xz
xz -cd linux-4.15.14.tar.xz | tar xvf -
cd ~/linux-4.15.14
git init
git apply --stat ~/skua.patch
git apply --check ~/skua.patch
git apply ~/skua.patch
cd ~/linux-4.15.14
cp /boot/config-$(uname -r) .config
make menuconfig
make # takes a long long time, 4+ hours on MOC
sudo make modules_install
sudo make install
sudo update-initramfs -c -k 4.15.14
sudo reboot
```

Use the following command to check if the kernel changed to 4.15.14

```shell
uname -r
```

### 2. Install Go and set up directory
```shell
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt-get update
sudo apt-get install -y golang-go
```
Set up GOPATH in the rc file, **remember to apply it whatever user later you will use to run skua**.

```shell
vi ~/.bashrc
```

Add the following line to then end of the rc file.

```shell
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

Apply the change

```shell
source ~/.bashrc
```

### 3. Install thrift v0.11.0

Set up github ssh key before clone projects from github.

```shell
sudo apt-get install -y automake bison flex g++ git libboost-all-dev libevent-dev libssl-dev libtool make pkg-config
cd
git clone git@github.com:apache/thrift.git
cd ~/thrift
git checkout 0.11.0
./bootstrap.sh
./configure
make # take some time
sudo make install
```

### 4. Install opentracing c++ client

```shell
cd
git clone git@github.com:opentracing/opentracing-cpp.git
cd ~/opentracing-cpp/
git checkout v1.4.2
mkdir .build
cd .build
cmake ..
make
sudo make install
sudo ldconfig # rebuild share library cache
cd
```

### 5. Install docker and jaeger 

```shell
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce
```

Install jaeger docker image

```shell
sudo docker pull jaegertracing/all-in-one:1.16
sudo docker run -d --name jaeger \
  -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 14250:14250 \
  -p 9411:9411 \
  --name jaeger_all_in_one \
  jaegertracing/all-in-one:1.16
```

Be cautious the script of skua sometime runs docker use root privilege. Change user privilege or script if needed.

```shell
sudo groupadd docker
sudo usermod -aG docker $USER
```

### 6. Install Babeltrace

```shell
sudo apt-get install -y babeltrace
``` 

### 7. Comply and install skua kernel module
[docc-lab/skua-jaeger-ctx](https://github.com/docc-lab/skua-jaeger-ctx)

```shell
cd
git clone git@github.com:docc-lab/skua-jaeger-ctx.git
cd ~/skua-jaeger-ctx/
make
sudo insmod jaeger_ctx.ko
```

### 8. Install skua modified lttng-tools v2.10
Install pre-request library

```shell
# install liburcu
cd 
git clone git://git.liburcu.org/userspace-rcu.git
cd ~/userspace-rcu
git checkout stable-0.9
sudo apt-get install -y autoconf automake autopoint
./bootstrap
./configure
make
sudo make install
sudo ldconfig # rebuild share library cache

sudo apt-get install -y libpopt-dev uuid-dev libxml2-dev liblttng-ust-dev asciidoc
```

Install skua modified lttng tools

```shell
cd ~/
git clone git@github.com:docc-lab/skua-lttng-tools.git
cd ~/skua-lttng-tools
./bootstrap
./configure
make
sudo make install
sudo ldconfig
```

Be cautious the script of skua sometime runs lttng use root privilege. Change user privilege or script if needed.

```shell
sudo groupadd lttng
sudo usermod -aG lttng $USER
```

### 9. Install modified version of lttng-modules v2.10

```shell
cd ~/
git clone git@github.com:docc-lab/skua-lttng-modules.git
cd ~/skua-lttng-modules
make
sudo make modules_install
sudo depmod -a
```

### 10. Fetch skua-lttng-adapter

```shell
go get -u github.com/docc-lab/skua-lttng-adapter
```

### 11. Install skua-patched Jaeger Client libraries

```shell
cd ~/
git clone git@github.com:docc-lab/skua-jaeger-client-cpp.git
cd ~/skua-jaeger-client-cpp
```

Regenerate submodule

```shell
git submodule update --init
find idl/thrift/ -type f -name \*.thrift -exec thrift -gen cpp -out src/jaegertracing/thrift-gen {} \;
git apply scripts/thrift-gen.patch
```

Install the library

```shell
cd ~/skua-jaeger-client-cpp
mkdir build
cd build
cmake ..
make
./app ../examples/config.yml
sudo make install
sudo ldconfig # rebuild share library cache
```

### 12. Start using skua

download skua script

```shell
git clone git@github.com:docc-lab/skua.git
```

download skua test program

```shell
git clone git@github.com:docc-lab/skua-tests.git
```

### 13. Use skua-test program


Start tracing:

```shell
cd ~/skua
./start-tracing.sh
./trace-process.sh
```

Run the C++ test program:

```shell
cd ~/skua-tests/correctness
./build.sh
./a.out
```

Log on the Jaeger's UI and check the result

```shell
http://your.ip.address:16686
```

Stop tracing:

```shell
cd ~/skua
./stop-tracing.sh
```

### Small Note

```shell
g++ -O3 -march=native -flto -std=c++11 ~/library/skua-jaeger-client-cpp/build/libjaegertracing.a main.cpp -L/usr/local/lib/ -lopentracing -ljaegertracing -lpthread

ldconfig
```

