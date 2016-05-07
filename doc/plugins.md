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

为了介绍更准确，介绍部分直接引用原文文档并翻译为中文。

[Heka 文档：http://hekad.readthedocs.org/](http://hekad.readthedocs.org/ "Heka 文档")

编写本文档时是基于 v0.10.0 版本，文档实际访问的地址是 http://hekad.readthedocs.io/en/v0.10.0/

```
Heka is a heavily plugin based system. Common operations such as adding data to Heka, processing it, and writing it out are implemented as plugins. Heka ships with numerous plugins for performing common tasks.
```
Heka 提供的服务是非常依赖于插件的。例如向 Heka 输入数据、在 Heka 中处理数据以及最终从 Heka 输出数据都需要通过不同插件来实现。Heka 附带了许多插件用于完成这些常见任务。

```
There are six different types of Heka plugins:
Inputs
Splitters
Decoders
Filters
Encoders
Outputs
```
Heka 插件有六种：

+ 输入器
+ 分割器
+ 解码器
+ 过滤器
+ 编码器
+ 输出器




### 插件日志处理流程



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