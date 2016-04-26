git clone https://github.com/mozilla-services/heka

git branch

git tag

git show v0.10.0

git checkout v0.10.0

vi /etc/profile
export GOPATH=/apps/gopath
export PATH=/apps/go/bin:$PATH

cd heka/
./build.sh


编译报错
```
Loading input failed: exec: "go": executable file not found in $PATH
```
vi build.sh 
```
#!/usr/bin/env bash

# set up our environment
. ./env.sh

NUM_JOBS=${NUM_JOBS:-1}

# build heka
mkdir -p $BUILD_DIR
cd $BUILD_DIR
cmake -DCMAKE_BUILD_TYPE=release ..
make -j $NUM_JOBS
```
看到文件中应该是通过 ./env.sh 配置环境，所以查看 ./env.sh
vi ./env.sh 
```
#!/usr/bin/env bash

# if the environment has been setup before clean it up
if [ $GOBIN ]; then
    PATH=$(echo $PATH | sed -e "s;\(^$GOBIN:\|:$GOBIN$\|:$GOBIN\(:\)\);\2;g")
fi

BUILD_DIR=$PWD/build
export CTEST_OUTPUT_ON_FAILURE=1
export GOPATH=$BUILD_DIR/heka
export LD_LIBRARY_PATH=$BUILD_DIR/heka/lib
export DYLD_LIBRARY_PATH=$BUILD_DIR/heka/lib
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH

```
很奇怪为什么 GOBIN 要配置为 $GOPATH/bin ？
修改该行：
```
export GOBIN=/apps/go/bin
```

之后重新编译：
```
./build.sh
```

编译成功
```
[  4%] Built target go-simplejson
[  7%] Built target protobuf
[ 11%] Built target xmlpath
[ 15%] Built target raw
[ 19%] Built target slices
[ 23%] Built target sets
[ 27%] Built target go-dockerclient
[ 30%] Built target toml
[ 33%] Built target go-ircevent
[ 37%] Built target raven-go
[ 40%] Built target heka-mozsvc-plugins
[ 43%] Built target amqp
[ 47%] Built target snappy
[ 51%] Built target gomock
[ 55%] Built target whisper-go
[ 59%] Built target go-notify
[ 63%] Built target uuid
[ 66%] Built target goamz
[ 70%] Built target g2s
[ 74%] Built target gostrftime
[ 78%] Built target gospec
[ 81%] Built target sarama
[ 81%] Built target GoPackages
[ 85%] Built target lua_sandbox
[ 86%] Built target heka_source
[ 86%] Built target message_matcher_parser
[ 86%] Built mock_pluginhelper_test.go
[ 86%] Built mock_pluginrunner_test.go
[ 87%] Built mock_decoder_test.go
[ 87%] Built mock_decoderrunner_test.go
[ 88%] Built mock_inputrunner_test.go
[ 88%] Built mock_filterrunner_test.go
[ 89%] Built mock_outputrunner_test.go
[ 89%] Built mock_input_test.go
[ 90%] Built mock_stataccumulator_test.go
[ 90%] Built mock_deliverer_test.go
[ 91%] Built mock_splitterrunner_test.go
[ 91%] Built mock_pluginhelper.go
[ 92%] Built mock_filterrunner.go
[ 92%] Built mock_decoderrunner.go
[ 93%] Built mock_outputrunner.go
[ 93%] Built mock_inputrunner.go
[ 93%] Built mock_decoder.go
[ 94%] Built mock_stataccumulator.go
[ 94%] Built mock_deliverer.go
[ 95%] Built mock_splitterrunner.go
[ 95%] Built mock_net_conn.go
[ 96%] Built mock_net_listener.go
[ 96%] Built mock_net_error.go
[ 97%] Built mock_whisperrunner_test.go
[ 97%] Built mock_amqpconnection_test.go
[ 98%] Built mock_amqpchannel_test.go
[ 98%] Built mock_amqpconnectionhub_test.go
[100%] Built mock_amqp_acknowledger.go
[100%] Built target mocks
Scanning dependencies of target hekad
[100%] Built target hekad
Scanning dependencies of target flood
[100%] Built target flood
Scanning dependencies of target heka-cat
[100%] Built target heka-cat
Scanning dependencies of target inject
[100%] Built target inject
Scanning dependencies of target logstreamer
[100%] Built target logstreamer
Scanning dependencies of target sbmgr
[100%] Built target sbmgr
Scanning dependencies of target sbmgrload
[100%] Built target sbmgrload
```