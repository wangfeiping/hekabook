# Heka 非权威指南

### - hekabook 开源学习手册：源码研究，配置管理，插件开发，发散式学习！

### 项目地址

本项目地址

* https://github.com/wangfeiping/hekabook
* https://coding.net/u/wangfeiping/p/hekabook/git

heka项目地址

* https://github.com/mozilla-services/heka

# 相关工具

### 自带工具集

### heka-flood

Heka压力测试工具。能够通过配置文件按照不同周期，协议，消息类型，单条消息大小等生成大量消息数据测试 Heka服务。

按照指定配置文件的指定配置名称执行测试：
```
heka-flood -config="./flood.toml" -test="test_name"
```
[flood.toml示例配置文件](https://github.com/mozilla-services/heka/blob/master/cmd/heka-flood/flood.toml "flood.toml示例配置文件")

### heka-inject

于版本 0.5新增。

向 Heka注入一条指定的消息数据，可用于调试和测试 Heka插件。

文档中说要求配置 使用了 Protobufs encoder插件的 TcpInput插件，但很明显 TcpInput插件应该配置 ProtobufDecoder；
```
-heka ip:port: 需要注入的 Heka服务实例/Heka instance to inject message
-hostname: 消息主机名/message hostname
-logger: 消息源名/message logger
-payload: 消息文本/message payload
-pid: 消息pid/message pid
-severity: 消息级别/message severity
-type: 消息类型/message type
```
-heka选项参数可指定访问的 Heka服务实例：
```
heka-inject -heka 127.0.0.1:514 -payload="Test message with high severity." -severity=1
```
Heka 示例配置脚本：
```
[pdecoder]
type = "ProtobufDecoder"

[TcpInput]
address = ":514"
decoder = "pdecoder"
use_tls = false

[RstEncoder]

[LogOutput]
message_matcher = "TRUE"
encoder = "RstEncoder"
```
如果按照 Heka示例配置脚本配置，会显示如下日志信息：
```
2016/06/09 20:14:14 
:Timestamp: 2016-06-09 12:14:14.122357144 +0000 UTC
:Type: inject.message
:Hostname: heka-dev
:Pid: 1648
:Uuid: e4653e14-3ddb-4fd6-990a-8c5f16fa1ed0
:Logger: Inject Client
:Payload: Test message with high severity.
:EnvVersion: 
:Severity: 1

2016/06/09 20:14:14 Decoder 'TcpInput-pdecoder-127.0.0.1': stopped
```

### [首页](../README.md "首页")
### [快速入门](./getting_started.md "快速入门")
### [插件与配置](./plugins.md "插件与配置")
### [相关工具](./tools.md "相关工具")
### [使用Lua开发插件](./lua_sandbox.md "使用Lua开发插件")
### 编译安装
### 使用Go开发插件
### 架构分析
### 源码分析