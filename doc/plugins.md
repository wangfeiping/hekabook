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

插件日志处理流程

```
[数据]=>[输入器/Inputs]=>[分割器/Splitters]=>[解码器/Decoders]=>[过滤器/Filters]=>[编码器/Encoders]=>[输出器/Outputs]
```

输入器/Inputs

Inputs 插件从外界获取数据，并注入 Heka 管道(pipeline)。插件可以通过多种方式获取数据：从文件系统读取文件；通过网络主动连接远程服务器获取数据；监听网络，接收外部推送数据，触发本地系统进程收集数据或运行其他处理机制。  
Inputs 插件必须用Go开发。

分割器/Splitters

Splitters 插件接收 Inputs 插件获取的数据并将这些数据分割成单个记录。  
Splitters 插件必须用Go开发。

解码器/Decoders

Decoders 插件将 Inputs 插件获取的数据转换为 Heka 内部数据结构。Decoders 通常负责解析、 反序列化，或提取非结构化数据的结构，
即将不可用的非结构化数据解码转换为可用于处理的结构化数据。  
Decoders 插件可以完全用Go开发，也可以用 Lua在沙盒(Sandbox)中实现核心逻辑。

过滤器/Filters

编码器/Encoders

输出器/Outputs

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