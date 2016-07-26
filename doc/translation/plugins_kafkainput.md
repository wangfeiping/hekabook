# Kafka Input

### [Kafka Input 原文配置文档](http://hekad.readthedocs.io/en/v0.10.0/config/inputs/kafka.html "Kafka Input 原文配置文档")

### 原文翻译：

类型名称：KafkaInput

连接Kafka 代理并从指定的标题和分区订阅消息。

注：Kafka 是一个常用的消息中间件。

配置项：

+ id (string):

客户端标识字符串。默认为主机名。

+ addrs ([]string)

Kafka 代理地址列表。

+ metadata_retries (int)

在分区正在选举领导者时元数据请求会重试多少次。默认为3次。

+ wait_for_election (uint32)

选举领导者时每次重试之间的等待时长（单位为毫秒）。默认为250毫秒。

+  background_refresh_frequency (uint32)

客户端在后台刷新集群元数据的频率。默认为600000毫秒（10分钟）。0为关闭此功能。

+ max_open_reqests (int)

        How many outstanding requests the broker is allowed to have before blocking attempts to send. Default is 4.

+ dial_timeout (uint32)

等待链接初始化成功的时长，直到超过该设定时长并返回错误信息（单位为毫秒）。默认为60000毫秒（一分钟）。

+ read_timeout (uint32)

等待响应的时长，直到超过设定时长并返回错误信息（单位为毫秒）。默认为60000毫秒（一分钟）。

+ write_timeout (uint32)

等待传输成功的时长，直到超过该设定时长并返回错误信息（单位为毫秒）。默认为60000毫秒（一分钟）。

+ topic (string)

Kafka 标题/topic（必须配置）。

+ partition (int32)

Kafka 标题分区/partition。默认为0。

+ group (string)

用于标识当前配置消费进程所属消费进程组的唯一标识字符串。多个进程如果设置了相同的组说明他们都从属与于这个组（相同组的消费进程会共同消费指定标题/topic 和分区/partition 的所有消息，但不会重复消费同一条消息）。默认为值为当前插件配置的id。

+ default_fetch_size (int32)

        The default (maximum) amount of data to fetch from the broker in each request. The default is 32768 bytes.

+ min_fetch_size (int32)

        The minimum amount of data to fetch in a request - the broker will wait until at least this many bytes are available. The default is 1, as 0 causes the consumer to spin when no messages are available.

+ max_message_size (int32)

可处理得消息最大大小 - 如果消息大于被设置会返回MessageTooLarge /消息过大错误？默认为0，表示不限制大小。

+ max_wait_time (uint32)

        The maximum amount of time the broker will wait for min_fetch_size bytes to become available before it returns fewer than that anyways. The default is 250ms, since 0 causes the consumer to spin when no events are available. 100-500ms is a reasonable range for most cases.

+ offset_method (string)

该配置用于决定从什么位置开始消费消息。可选配置为：

    Manual 插件将会跟踪消息消费的位置，会从上一次中断的位置恢复（默认配置）。  
    Newest 插件将会从最新有效位置开始读取消息。  
    Oldest 插件将会从最早有效位置开始读取消息。  

+ event_buffer_size (int)

        The number of events to buffer in the Events channel. Having this non-zero permits the consumer to continue fetching messages in the background while client code consumes events, greatly improving throughput. The default is 16.







### 翻译词典：

```
broker - 代理
topic - 标题
partition - 分区
leader - 领导者
```
