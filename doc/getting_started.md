# Heka 非权威指南

hekabook 开源学习手册：  
源码研究，配置管理，插件开发，发散式学习！

### 项目地址

本项目地址

* https://github.com/wangfeiping/hekabook
* https://coding.net/u/wangfeiping/p/hekabook/git

heka项目地址

* https://github.com/mozilla-services/heka

# 快速入门

### 源码编译安装

在 CentOS-6.6-x86_64-minimal.iso 虚拟机中使用 Go 1.6 和 heka 0.10.0 编译成功，
但是运行时如果配置了 lua sandbox 的插件就会报错，原因好像是 Go 1.6 建议不要在 Go 调用 C 库时传递指针，所以运行时报错了。
看 heka 的issue中说好像修改编译配置，可以忽略这个问题。

编译安装等以后进一步研究项目源码时再研究和补充文档吧。

### 安装包安装 heka

官方参考文档：http://hekad.readthedocs.org/en/v0.10.0/

下载安装包：https://github.com/mozilla-services/heka/releases

以 heka-0_10_0-linux-amd64.tar.gz 为例

```
mkdir /apps  
cd /apps  
wget https://github.com/mozilla-services/heka/releases/download/v0.10.0/heka-0_10_0-linux-amd64.tar.gz  
tar -xzvf heka-0_10_0-linux-amd64.tar.gz  
```

### 配置并运行服务

在 heka-0_10_0-linux-amd64/bin 路径下创建 heka.toml 配置文件

这个配置并不能完全正常的运行，虽然 udp 可以正常接收到发送的文本数据，tcp 却完全没有任何反应，似乎没有接收到任何数据。

```
[TcpInput]
address = ":514"

[UdpInput]
address = ":514"
splitter = "" # 或 "NullSplitter"

[PayloadEncoder]
append_newlines = false

[LogOutput]
message_matcher = "TRUE"
encoder = "PayloadEncoder"
```

使用如下命令可以启动 heka，当然这只是为了测试，并不是后台服务（守护进程）的方式，后台服务方式在后面说明。

```
cd heka-0_10_0-linux-amd64/bin
./hekad -config heka.toml
```

使用如下命令可以分别以 tcp 和 udp 协议发送文本内容到指定地址和端口。
其中参数 "-u" 即为指定使用 udp 协议：

```
nc 172.17.3.180 514
nc 172.17.3.180 514 -u
```

运行 nc 程序后，输入文本并按回车键，即可发送数据，在 heka 输出中就应该可以看到接收到的数据内容。

nc 测试端输入：

```
nc 172.17.3.180 514 -u
test

```

heka 启动信息，最后一行为接收到的测试数据。

```
2016/04/08 11:36:57 Pre-loading: [TcpInput]
2016/04/08 11:36:57 Pre-loading: [UdpInput]
2016/04/08 11:36:57 Pre-loading: [PayloadEncoder]
2016/04/08 11:36:57 Pre-loading: [LogOutput]
2016/04/08 11:36:57 Pre-loading: [ProtobufDecoder]
2016/04/08 11:36:57 Loading: [ProtobufDecoder]
2016/04/08 11:36:57 Pre-loading: [ProtobufEncoder]
2016/04/08 11:36:57 Loading: [ProtobufEncoder]
2016/04/08 11:36:57 Pre-loading: [TokenSplitter]
2016/04/08 11:36:57 Loading: [TokenSplitter]
2016/04/08 11:36:57 Pre-loading: [HekaFramingSplitter]
2016/04/08 11:36:57 Loading: [HekaFramingSplitter]
2016/04/08 11:36:57 Pre-loading: [NullSplitter]
2016/04/08 11:36:57 Loading: [NullSplitter]
2016/04/08 11:36:57 Loading: [PayloadEncoder]
2016/04/08 11:36:57 Loading: [TcpInput]
2016/04/08 11:36:57 Loading: [UdpInput]
2016/04/08 11:36:57 Loading: [LogOutput]
2016/04/08 11:36:57 Starting hekad...
2016/04/08 11:36:57 Output started: LogOutput
2016/04/08 11:36:57 MessageRouter started.
2016/04/08 11:36:57 Input started: TcpInput
2016/04/08 11:36:57 Input started: UdpInput
2016/04/08 11:37:00 test

```

虽然 tcp 完全没有任何反应，hekad 没有输出任何数据，
但是当测试客户端退出 nc 程序时，hekad 却又会输出一条日志说 tcp 的链接断开了，这说明 nc 和 heka 应该是正常建立了 tcp 连接。

```
2016/04/08 11:37:14 Decoder 'TcpInput-ProtobufDecoder-172.17.3.180': stopped
```

按照如下配置修改文件 heka.toml，并重启 heka 服务，tcp 协议的监听端口可以正常运行。

```
[newline_splitter]
type = "TokenSplitter"
delimiter = '\n'

[prdecoder]
type = "PayloadRegexDecoder"
match_regex = '(\S*\n)'

[TcpInput]
address = ":514"
splitter = "newline_splitter"
decoder = "prdecoder"
use_tls = false

[UdpInput]
address = ":514"

[PayloadEncoder]
append_newlines = true

[LogOutput]
message_matcher = "TRUE"
encoder = "PayloadEncoder"
```

从配置上推断，tcp 需要分割器(splitter)和解码器(decoder)，可能是由于 tcp 会建立和保持连接，数据是流式的，因此需要分割和解码才能获取正确的数据。
不过奇怪的是，查看文档，tcp 是有默认配置的，不知道这个默认配置需要如何工作，这个需要放在以后深入学习时继续研究了。

### 后台运行

后台运行，可以使用如下命令

```
nohup ./hekad -config heka.toml &
```

不过这种方式并不方便，首先每次启动要么进入安装路径：

```
cd /apps/heka-0_10_0-linux-amd64/bin
./hekad -config heka.toml
```

或者启动命令输入完整路径：

```
/apps/heka-0_10_0-linux-amd64/bin/hekad -config /apps/heka-0_10_0-linux-amd64/bin/heka.toml
```

另外，关闭和重启时还要查询 pid 通过 kill 关闭 hekad，并使用上面的方式重新启动 hekad：

```
ps -ef | grep hekad
kill -QUIT $pid
```

最好的方式当然还是通过 service 启动或重启 hekad。

参考文档：https://github.com/mozilla-services/heka/wiki/Sample--etc-init.d-hekad-file

本项目中的 conf/etc/init.d/hekad 就是根据上面的参考创建的脚本文件，在系统文件路径 /etc/init.d/ 创建该脚本。
并需要安装一个软件"daemon"，http://libslack.org/daemon/：

```
curl -O http://libslack.org/daemon/download/daemon-0.6.4.tar.gz
tar -xzvf daemon-0.6.4.tar.gz
cd daemon-0.6.4
./config
make
make install
```

然后执行如下命令，安装 service 服务：

```
chmod a+x /etc/init.d/hekad
chkconfig --add hekad
```

命令执行成功后，就可以通过 service，启动、停止或重启、查询 hekad 了：

```
service hekad start
service hekad stop
service hekad restart
service hekad status
```

### [首页](../README.md "首页")
### [快速入门](./getting_started.md "快速入门")
### [相关工具](./tools.md "相关工具")
### [使用Lua开发插件](./lua_sandbox.md "使用Lua开发插件")
### 编译安装
### 使用Go开发插件
### 架构分析
### 源码分析

