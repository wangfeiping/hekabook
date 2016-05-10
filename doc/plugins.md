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

从名字猜就是某种消息队列的输入插件，由于没有接触过，简单搜索了解一下，希望以后有机会进一步学习。  
发散一下，阅读学习的资料：  
AMQP（高级消息队列协议）是一个异步消息传递所使用的应用层协议规范。作为线路层协议，而不是API（例如JMS2），AMQP客户端能够无视消息的来源任意发送和接受信息。现在，已经有相当一部分不同平台的服务器3和客户端可以投入使用4。  
AMQP的原始用途只是为金融界提供一个可以彼此协作的消息协议，而现在的目标则是为通用消息队列架构提供通用构建工具。因此，面向消息的中间件（MOM）系统，例如发布/订阅队列，没有作为基本元素实现。反而通过发送简化的AMQ实体，用户被赋予了构建例如这些实体的能力。这些实体也是规范的一部分，形成了在线路层协议顶端的一个层级：AMQP模型。这个模型统一了消息模式，诸如之前提到的发布/订阅，队列，事务以及流数据，并且添加了额外的特性，例如更易于扩展，基于内容的路由。  

[AMQP和RabbitMQ入门](http://www.infoq.com/cn/articles/AMQP-RabbitMQ "AMQP和RabbitMQ入门")

[RabbitMQ, ZeroMQ, Kafka](http://www.zhihu.com/question/22480085 "RabbitMQ, ZeroMQ, Kafka")

[RabbitMQ和Kafka](http://my.oschina.net/u/236698/blog/501834?utm_source=tuicool&utm_medium=referral "RabbitMQ和Kafka")

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