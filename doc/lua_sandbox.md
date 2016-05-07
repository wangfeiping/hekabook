# Heka 非权威指南

### - hekabook 开源学习手册：源码研究，配置管理，插件开发，发散式学习！

### 项目地址

本项目地址

* https://github.com/wangfeiping/hekabook
* https://coding.net/u/wangfeiping/p/hekabook/git

heka项目地址

* https://github.com/mozilla-services/heka

# 使用Lua开发插件

### 系统时间

lua sandbox 开发过程中，所有获取的时间都是格林威治时间，目前没有找到相关配置，也还没有查看相关源码。
为了正确获取当前系统的本地时间，临时解决办法就是直接加上8个小时。

获取时间的方法包括：
```
os.time()
os.date()
io.popen() -- 通过系统调用 api 查询 文件更新时间；
os.execute() -- 通过系统调用 api 获取系统时间
```

### filter

+ 禁用 'io'

在使用lua开发 filter 时，不允许使用任何的 io，网络或文件操作都不允许，会在启动初始化时就报错。
```
 Initialization failed for XXXXXX: module 'io' disabled
```

因此即使是想要记录一些 lua 开发的 filter 插件运行时的信息（如：统计数据，运行时错误)，也需要使用 output 插件来输出。

+ 单条数据缓存

运行时，lua filter 会由于数据包太大停止运行，需要调整相应的缓存大小：
```
[log_filter]
type = "SandboxFilter"
filename = "log_filter.lua"
ticker_interval = 1
message_matcher = "Logger == 'log_input'"
output_limit = 65600
```

### output

### lua 语言性能调优

### [首页](../README.md "首页")
### [快速入门](./getting_started.md "快速入门")
### [相关工具](./tools.md "相关工具")
### [使用Lua开发插件](./lua_sandbox.md "使用Lua开发插件")
### 编译安装
### 使用Go开发插件
### 架构分析
### 源码分析