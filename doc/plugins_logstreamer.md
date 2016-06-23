# Logstreamer Input

### [Logstreamer Input 原文配置文档](http://hekad.readthedocs.io/en/v0.10.0/config/inputs/logstreamer.html "Logstreamer Input 原文配置文档")

### 原文翻译：

自版本 0.5 新增：

类型名称：LogstreamerInput

能够持续读取一个日志文件，或持续读取一个或多个日志流形成的一个或多个有序的日志数据源。

配置项：

+ hostname (string):

hostname/主机名用于消息中，默认为部署机器的主机名。在机器存在多个（interfaces?）主机名的情况下也可以通过该配置项显示的设置以确保使用正确的主机名。

+ oldest_duration (string):

可配置一个期限字符串（例如：“2s” - 2秒，“2m” - 2分钟，“2h” - 2小时）。日志文件的最后修改时间比期限字符串设置的时间还早则说明已经过期，插件将不会解析处理该日志文件。默认为“720h”（720小时，等于30天）。

+ journal_directory (string):




    journal_directory (string):

        The directory to store the journal files in for tracking the location that has been read to thus far. By default this is stored under heka’s base directory.

+ log_directory (string):


    log_directory (string):

        The root directory to scan files from. This scan is recursive so it should be suitably restricted to the most specific directory this selection of logfiles will be matched under. The log_directory path will be prepended to the file_match.

+ rescan_interval (int):

    rescan_interval (int):

        During logfile rotation, or if the logfile is not originally present on the system, this interval is how often the existence of the logfile will be checked for. The default of 5 seconds is usually fine. This interval is in milliseconds.

+ file_match (string):

    file_match (string):

        Regular expression used to match files located under the log_directory. This regular expression has $ added to the end automatically if not already present, and log_directory as the prefix. WARNING: file_match should typically be delimited with single quotes, indicating use of a raw string, rather than double quotes, which require all backslashes to be escaped. For example, ‘access\.log’ will work as expected, but “access\.log” will not, you would need “access\\.log” to achieve the same result.

+ priority (list of strings):

    priority (list of strings):

        When using sequential logstreams, the priority is how to sort the logfiles in order from oldest to newest.

+ differentiator (list of strings):

    differentiator (list of strings):

        When using multiple logstreams, the differentiator is a set of strings that will be used in the naming of the logger, and portions that match a captured group from the file_match will have their matched value substituted in.

+ translation (hash map of hash maps of ints):

    translation (hash map of hash maps of ints):

        A set of translation mappings for matched groupings to the ints to use for sorting purposes.

+ splitter (string, optional):

默认为“TokenSplitter”，将把日志流中的每一行作为一个Heka 消息进行分割处理。

### [Logstreamer Input 原文示例文档](http://hekad.readthedocs.io/en/v0.10.0/pluginconfig/logstreamer.html#logstreamerplugin "Logstreamer Input 原文示例文档")

### 原文翻译：

自版本 0.5 新增：

LogstreamerInput 插件能够扫描、排序和读取用户自定义的连续日志流，或基于用户定义匹配规则的多个存在差别的日志流。

日志流是通过一个或多个连续日志文件传播的线性数据流。例如，Apache 或nginx 服务器通常会为每个域名产生两个日志流：访问日志（access log ）和错误日志（error log ）  。每个日志流会被写入一个可能会定时清空的日志文件（比较令人反感的做法）或被写入一个会定时轮换备份的日志文件（好一些的做法），而这些轮换备份的文件会保留一些代表历史的版本数字（例如： access-example.com.log， access-example.com.log.0， access-example.com.log.1 等等）。或者，更好一点的情况是，服务器会在定时轮换备份文件时创建时间戳以便更好地标示每一个轮换备份文件（例如： access- example.com-2014.01.28.log， access-example.com-2014.01.27.log， access- example.com-2014.01.26.log 等等）。Logstreamer 插件的功能是按照特定类型日志流的命名和排序约定（例如：“all of the nginx server’s domain access logs”），并根据该约定检索指定的文件夹按照正确的顺序装载正确的文件。Logstreamer 插件也能够跟踪自身处理日志流的位置，因此它能够在重启甚至暂停阶段发生文件轮换备份之后恢复到正确位置重新开始处理。

为了使解析多日志流更简单，Logstreamer 插件可以同时为所有需要解析的日志流配置同一个解码器。



### 翻译词典：

```
tail - 持续读取
logstream - 日志流
```
