# 配置hekad

### [配置hekad 原文文档](http://hekad.readthedocs.io/en/v0.10.0/config/index.html "配置hekad 原文文档")

### 原文翻译：

### 配置hekad

hekad 配置文件描述了启动时需要装载哪些“输入”、“分割”、“解码”、“过滤”、“编码”和“输出”插件。配置文件为TOML 格式，TOML 和INI 配置格式很相近，但支持更丰富一些的数据结构以及嵌套。

如果hekad 启动时的config 参数设置为一个文件夹路径而不是文件，那么所有该文件夹下以“.toml”为文件名结尾的文件都会被读取并组合成一个配置实例。文件夹中的那些不是以“.toml”结尾的文件则会被忽略。配置文件的合成将按照字母顺序，合并顺序靠后的设置将覆盖考前冲突的设置项生效。

配置文件可以分为多个段落，每个段落是一个独立的插件实例。段落名就是插件的实例名，“type”参数则说明插件的类型；而该类型必须是通过pipeline.RegisterPlugin 方法注册的类型。例如，如下的配置即为一个名称为“tcp:5565”类型为“TcpInput”的Heka 插件，

```
[tcp:5565]
type = "TcpInput"
splitter = "HekaFramingSplitter"
decoder = "ProtobufDecoder"
address = ":5565"
```

如果设置的插件实例名称恰好与插件的类型名称相同，就可以在该段落中省略“type”参数，设置的插件名称也会被作为插件类型。因此，如下的配置中，插件实例名称“TcpInput”，同时也是插件的类型“TcpInput”：

```
[TcpInput]
address = ":5566"
splitter = "HekaFramingSplitter"
decoder = "ProtobufDecoder"
```

注意：只要各自的配置相互间没有干扰，同一个类型的插件可以有多个实例。

配置段落中除了“type”（插件类型）之外的任何值，比如上面示例配置中的“address”（服务地址），将作为内部配置传给插件（见“插件配置”）。

如果插件在启动时装载失败，hekad 将退出启动。当hekad 正在运行时如果插件运行失败（由于连接丢失，无法写文件等），那么hekad 也会关闭或在该插件支持重启的情况下重启插件。当插件重启时，hekad 可能会停止接受消息，直到该插件恢复操作 （仅是对过滤器和输出插件来说）。

插件通过实现Restarting 接口声明他们自身支持重启（见重启插件）。支持重启的插件也可以有空值其自身重启行为的配置。

内部诊断每隔 30秒会扫描消息包，以便在Heka 插件可能出现问题时报告并锁定可能未能正确回收该消息包的具体插件。

### 全局配置项

可以在配置文件中声明一个名为[hekad]的段落从而为hekad 守护进程配置一些全局选项。

+ cpuprof (string output_file):

打开hekad 的CPU 性能分析；输出数据会记录到 配置的output_file 输出文件中。

+ max_message_loops (uint):

消息重新被注入系统的最大次数。用于避免在过滤器到过滤器之间无限的循环消息；默认为4。

+ max_process_inject (uint):

沙盒过滤器插件中ProcessMessage 方法在单次调用中所能注入消息的最大数量，默认为1。

+ max_process_duration (uint64):

沙盒过滤器插件的ProcessMessage 方法在单次调用中被结束前能够耗费的最大纳秒数，默认为100000纳秒。

+ max_timer_inject (uint):

沙盒过滤器插件中TimerEvent 方法在单次调用中所能注入消息的最大数量，默认为10。

+ max_pack_idle (string):

被heka 认为泄露之前，数据包可以空闲的时间（例如：“2s”、“2m”、“2h”）。如果过滤器或输出插件由于程序错误出现太多的数据包泄露将导致heka 最终终止运行。该设置明确表示何时数据包会被认为发生了泄露。

+ maxprocs (int):

设置使用多内核；默认为只是用一个内核。更多的内核通常能够提高消息的吞吐量。一般情况下该值设置为实际内核数的两倍即可达到最佳处理性能。这里假定每一个内核都是超线程。

+ memprof (string output_file):

打开hekad 的内存性能分析；输出数据会记录到 配置的output_file 输出文件中。

+ poolsize (int):

消息池中可以缓存的最大消息数。默认为100。

+ plugin_chansize (int):

各类Heka 插件输入管道的缓存大小。默认为30。

+ base_dir (string):

Heka 的基础工作目录，用于进程和服务器重启的持久化存储。已启动的hekad 进程一定已经对该目录进行过读写的操作访问。默认为/var/cache/hekad（微软视窗系统下为c:\var\cache\hekad）。

+ share_dir (string):

Heka “分享目录”的根路径，Heka 会在该目录下寻找自己需要的特定资源。hekad 进程对该目录应该仅有只读权限。该目录默认为/usr/share/heka（微软视窗系统下为c:\var\share\heka）。

于版本0.6新增：

+ sample_denominator (int):

        Specifies the denominator of the sample rate Heka will use when computing the time required to perform certain operations, such as for the ProtobufDecoder to decode a message, or the router to compare a message against a message matcher. Defaults to 1000, i.e. duration will be calculated for one message out of 1000.

+ pid_file (string):

hekad 进程的进程id 将会写入到pid_file 指定的文件中。hekad 进程必须对该配置的路径（pid_file 的父目录，该目录不能使自动创建的）拥有读和写的访问权限。hekad 正常成功的退出时pid_file 会被删除。（hekad 启动时？）如果该目录下已经存在pid （进程id），hekad 当前启动进程会检查是否存在运行的进程，如果找到一个已经运行的进程，当前启动进程会报错并退出。

于版本0.9新增：

+ hostname (string):

hostname 用于Heka 被要求提供本地主机名时返回的内容。缺省情况下会返回Golang 语言中os.Hostname() 方法调用中返回的值。

+ max_message_size (uint32):

可被处理的消息的最大字节数。默认为64KiB。

注：
沙盒过滤器插件中也有一个配置output_limit
```
如下：
[log_filter]
type = "SandboxFilter"
filename = "log_filter.lua"
......
output_limit = 65600

如果没有配置output_limit 参数的话，如果沙盒过滤器插件接收到大于64KiB 的消息，报一个错误消息后会停止插件运行而hekad 进程本身还正常运行，即使后续消息没有超过限制也无法正常处理。

有时间需要将max_message_size 和output_limit 两个参数组合测试一下。
```
KiB 与 KB 的区别?
```
1KiB=2^10=1024byte
1KB=10^3=1000byte
同理
1MiB=2^20=1048576=1024KiB
1GiB=2^30=1,073,741,824=1024MiB

1MB=10^6=1000000=1000KB
1GB=10^9=1000000000=1000MB
```

于版本0.10新增：

+ log_flags (int):

用于控制STDOUT 和STDERR 输出日志的前缀。通常值可设为3（日期和时间，默认值）或0（无前缀）。详见 “https://golang.org/pkg/log/#pkg-constants Go 文档”。

+ full_buffer_max_retries (int):

        When Heka shuts down due to a buffer filling to capacity, the next time Heka starts it will delay startup briefly to give the buffer a chance to drain, to alleviate the back-pressure. This setting specifies the maximum number of intervals (max 1s in duration) Heka should wait for the buffer size to get below 90% of capacity before deciding that the issue is not resolved and continuing startup (or shutting down).

### 翻译词典：

```
TOML - Github开源项目
sandbox - 沙盒
```

### [插件与配置](./plugins.md "插件与配置")
