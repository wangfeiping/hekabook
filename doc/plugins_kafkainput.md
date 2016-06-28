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

        Kafka topic (must be set).

    partition (int32)

        Kafka topic partition. Default is 0.

    group (string)

        A string that uniquely identifies the group of consumer processes to which this consumer belongs. By setting the same group id multiple processes indicate that they are all part of the same consumer group. Default is the id.

    default_fetch_size (int32)

        The default (maximum) amount of data to fetch from the broker in each request. The default is 32768 bytes.

    min_fetch_size (int32)

        The minimum amount of data to fetch in a request - the broker will wait until at least this many bytes are available. The default is 1, as 0 causes the consumer to spin when no messages are available.

    max_message_size (int32)

        The maximum permittable message size - messages larger than this will return MessageTooLarge. The default of 0 is treated as no limit.

    max_wait_time (uint32)

        The maximum amount of time the broker will wait for min_fetch_size bytes to become available before it returns fewer than that anyways. The default is 250ms, since 0 causes the consumer to spin when no events are available. 100-500ms is a reasonable range for most cases.

    offset_method (string)

        The method used to determine at which offset to begin consuming messages. The valid values are:
            Manual Heka will track the offset and resume from where it last left off (default).
            Newest Heka will start reading from the most recent available offset.
            Oldest Heka will start reading from the oldest available offset.

    event_buffer_size (int)

        The number of events to buffer in the Events channel. Having this non-zero permits the consumer to continue fetching messages in the background while client code consumes events, greatly improving throughput. The default is 16.







### 翻译词典：

```
broker - 代理
topic - 标题
partition - 分区
leader - 领导者
```
