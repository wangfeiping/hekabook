git clone https://github.com/mozilla-services/heka

git branch

git tag

git show v0.10.0

git checkout v0.10.0

vi /etc/profile
export GOPATH=/apps/gopath
export GOROOT=/apps/go
export GOBIN=$GOROOT/bin
export GOARCH=amd64
export GOOS=linux
export PATH=.:$PATH:$GOBIN

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
后来才发现，hekad编译后生成的可执行程序都生成在 GOBIN 指定的路径下，  
另外也很奇怪明明在 /etc/profile 的 PATH 参数中配置了 Go 的 bin 路径，为什么还说找不到？

修改最后一行：
```
export PATH=$GOBIN:/apps/go/bin:$PATH
```

之后重新编译：
```
./build.sh
```

编译成功
```
......
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

在 heka/bin 目录下生成了可执行程序
```
heka-cat
hekad
heka-flood
heka-inject
heka-logstreamer
heka-sbmgr
heka-sbmgrload
mockgen
protoc-gen-gogo
```

### 运行

复制 lua 第三方包，安装包中 lua 第三方包是在 share/heka/lua_io_modules/ 路径下，不知为什么编译包中则出现在 lib/luasandbox/io_modules/ 路径下。
cp -r ../lib/luasandbox/io_modules/ ./share/lua_modules

如果使用的是 Go 1.6编译安装，使用 lua_sandbox 时，启动会报错。
```
panic: runtime error: cgo argument has Go pointer to Go pointer
```

GODEBUG=cgocheck=0 ./bin/hekad -config /etc/hekad/hekad.toml

发送测试数据
nc -u 127.0.0.1 514

查看 hekad 日志
tail -f hekad.log
