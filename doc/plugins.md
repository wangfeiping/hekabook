# Heka 非权威指南

Hekabook 开源学习手册：  
源码研究，配置管理，插件开发，发散式学习！

### 项目地址

Hekabook 项目地址

* https://github.com/wangfeiping/hekabook
* https://coding.net/u/wangfeiping/p/hekabook/git

Heka 项目地址

* https://github.com/mozilla-services/heka

# 自有插件

Heka 的自有插件还是相当丰富的，包括可以直接配置使用的Go开发的插件，以及Lua 开发实现的 Sandbox插件。

为了介绍更准确，介绍部分直接将原文文档翻译为中文。

[Heka 文档：http://hekad.readthedocs.org/](http://hekad.readthedocs.org/ "Heka 文档")

编写本文档时是基于 v0.10.0 版本，文档实际访问的地址是 http://hekad.readthedocs.io/en/v0.10.0/

Heka 提供的服务是非常依赖于插件的。例如向 Heka 输入数据、在 Heka 中处理数据以及最终从 Heka 输出数据都需要通过不同插件来实现。Heka 附带了许多插件用于完成这些常见任务。

Heka 插件有六种：

+ 输入器
+ 分割器
+ 解码器
+ 过滤器
+ 编码器
+ 输出器

### 插件日志处理流程

```
[数据]=>[输入器/Inputs]=>[分割器/Splitters]=>[解码器/Decoders]=>[过滤器/Filters]=>[编码器/Encoders]=>[输出器/Outputs]
```

### 输入器/Inputs

Inputs 插件从外界获取数据，并注入 Heka 管道(pipeline)。插件可以通过多种方式获取数据：从文件系统读取文件；通过网络主动连接远程服务器获取数据；监听网络，接收外部推送数据，触发本地系统进程收集数据或运行其他处理机制。  
Inputs 插件必须用Go开发。

### 分割器/Splitters

Splitters 插件接收 Inputs 插件获取的数据并将这些数据分割成单个记录。  
Splitters 插件必须用Go开发。

### 解码器/Decoders

Decoders 插件将 Inputs 插件获取的数据转换为 Heka 内部数据结构。Decoders 通常负责解析、 反序列化，或提取非结构化数据的结构，
即将不可用的非结构化数据解码转换为可用于处理的结构化数据。  
Decoders 插件可以完全用Go开发，也可以用 Lua在沙盒(Sandbox)中实现核心逻辑。

### 过滤器/Filters

Filters 插件是 Heka 的处理引擎。Filters 插件可配置用于接收匹配指定特征(使用 Heka 消息匹配语法)的消息并能够执行监测、 聚合等数据的处理。Filters 插件也能够生成新的消息，并注入 Heka 管道，例如包含聚合数据的摘要消息，发现可疑异常的通知消息，或是将显示在 Heka 控制台实时监控图中的循环缓存数据(circular buffer data)消息。  
Filters 插件可以完全用Go开发，也可以用 Lua在沙盒(Sandbox)中实现核心逻辑。可以配置 Heka 允许 Lua Filters 插件动态注入到 Heka 的运行实例中，而无需重新配置或重新启动 Heka 进程，甚至不需要通过 shell 访问 Heka 运行的服务器。

### 编码器/Encoders

Encoders 插件与 Decoders 插件正好相反。插件从 Heka 消息结构中提取数据并生成任意字节流数据。Encoders 插件被嵌入在 Outputs 插件中；Encoders 插件处理序列化，Outputs 插件则负责处理与外界交互的具体细节。  
Encoders 插件可以完全用Go开发，也可以用 Lua在沙盒(Sandbox)中实现核心逻辑。

### 输出器/Outputs

Outputs 插件将 Encoders 插件序列化的数据发送到 Heka 外部目标。他们处理与网络、 文件系统或任何其他外部资源进行交互的所有细节。和 Filters 插件一样，Outputs 插件可以配置使用 Heka 消息匹配语法，因此可以只接收和发送匹配指定特征的消息。  
Outputs 插件必须用Go开发。

注：可能是文档与项目并不完全同步？至少我在实际的项目中是开发并使用了基于 Lua Sandbox 的 Outputs 插件的。
会在“[使用Lua开发插件](./lua_sandbox.md "使用Lua开发插件")”中详细介绍。

### AMQP Input

从名字猜就是某种消息队列的输入插件，由于没有接触过，目前工作也还不需要使用。简单搜索了解一下，希望以后有机会进一步学习。  
发散一下，初步了解一下什么是AMQP：  
AMQP（高级消息队列协议）是一个异步消息传递所使用的应用层协议规范。作为线路层协议，而不是API（例如JMS），AMQP客户端能够无视消息的来源任意发送和接受信息。现在，已经有相当一部分不同平台的服务器和客户端可以投入使用。  
AMQP的原始用途只是为金融界提供一个可以彼此协作的消息协议，而现在的目标则是为通用消息队列架构提供通用构建工具。因此，面向消息的中间件（MOM）系统，例如发布/订阅队列，没有作为基本元素实现。反而通过发送简化的AMQ实体，用户被赋予了构建例如这些实体的能力。这些实体也是规范的一部分，形成了在线路层协议顶端的一个层级：AMQP模型。这个模型统一了消息模式，诸如之前提到的发布/订阅，队列，事务以及流数据，并且添加了额外的特性，例如更易于扩展，基于内容的路由。  

[AMQP和RabbitMQ入门](http://www.infoq.com/cn/articles/AMQP-RabbitMQ "AMQP和RabbitMQ入门")

[RabbitMQ, ZeroMQ, Kafka](http://www.zhihu.com/question/22480085 "RabbitMQ, ZeroMQ, Kafka")

[RabbitMQ和Kafka](http://my.oschina.net/u/236698/blog/501834?utm_source=tuicool&utm_medium=referral "RabbitMQ和Kafka")

### Sandbox Input

很明显已经支持了 Lua Sandbox 开发 Inputs 插件，应该是文档没有同步更新吧。
不过暂时还没有用到，以后有需要再完善内容。

### 配置示例

Heka 配置文件为 TOML 格式（也是一个开源项目[TOML](https://github.com/toml-lang/toml "TOML")）。

官方文档中给出的最简单示例，功能为读取指定文件并输出到标准输出。如下：
```
[LogstreamerInput]
log_directory = "/var/log"
file_match = 'auth\.log'

[PayloadEncoder]
append_newlines = false

[LogOutput]
message_matcher = "TRUE"
encoder = "PayloadEncoder"
```

先介绍这三个插件：

### LogstreamerInput

读取指定配置文件（或正则匹配的多个文件），文件如果有更新，会自动读取新增的内容，例如：日志文件。
和 FilePollingInput 不同，FilePollingInput 会每次都读取整个文件的内容。

示例如上。

### PayloadEncoder

似乎并没有做什么特别处理，所以我管它叫“原文编码器”，就是直接使用原文（没有进行编码）。
不过（append_newlines = false）为每一条数据增加了一个换行（因为实际工作中有些应用或设备的日志数据是没有换行的）。

示例如上。

### LogOutput

标准输出插件，将PayloadEncoder处理过的数据全部（message_matcher = "TRUE"）输出到标准输出（显示终端）中。

示例如上。

上面是例子中的插件，实际工作共还用到了一些，简单记录一下，以后慢慢完善。

### RstEncoder

这个插件也许是初学阶段最重要的插件了，全称 Restructured Text Encoder，经 RstEncoder 处理的 Heka 消息会生成解构化的文本数据（Restructured Text），就是将内存中所有该消息相关的域（fields ）与属性（attributes）等数据用文本的形式整理出来，对于调试很有帮助，尤其是与 LogOutput 插件组合使用，可以方便的查看数据的状态和各部分值。

否则经常会碰到某些数据文档示例中就是简单的使用，但是根本不知道这个数据是怎么产生的，也不知道应该去哪里设置或查询。我感觉这是我学习 Heka 和阅读 Heka 文档的最大难点。

### UdpInput

以UDP协议监听指定端口。

### TcpInput

以TCP协议监听指定端口。

### KafkaOutput

kafka输出插件，向kafka写入（从Heka输出）数据（kafka生产者？）

### KafkaInput

kafka输入插件，从kafka读取（向Heka输入）数据（kafka消费者？）

### PayloadRegexDecoder

正则解码器，就是按照一定正则将数据在解码阶段解析出来，提取有用部分，例如有些使用logstash传输日志的服务会将数据结构化（例如转换为json），并附带一些日志本身之外的数据（版本，日志源文件路径，时间戳等）。

### FileOutput

文件输出插件

### HttpOutput

Http输出插件

### SandboxFilter 和 SandboxOutput

我的工作中，日志处理的主要逻辑在Filter和Output中，为了便于调试所以使用Lua开发，即使用了SandboxFilter 和 SandboxOutput插件，这部分在[使用Lua开发插件](./lua_sandbox.md "使用Lua开发插件")再继续介绍。

### [首页](../README.md "首页")
### [快速入门](./getting_started.md "快速入门")
### [自有插件](./plugins.md "自有插件")
### [相关工具](./tools.md "相关工具")
### [使用Lua开发插件](./lua_sandbox.md "使用Lua开发插件")
### 编译安装
### 使用Go开发插件
### 架构分析
### 源码分析
### 尝试：如何设计一个每秒处理10万条的日志服务？