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

该配置路径用于存储已经读取文件的跟踪记录，默认为heka 的base 路径（可在heka 配置文件中配置base 路径：[hekad] -> base_dir）。

经测试运行时会在该路径下创建一个logstreamer文件夹，并在该文件夹中针对heka 配置文件生成对应的跟踪记录文件。

+ log_directory (string):

该配置为扫描文件的根路径，由于扫描是递归的，因此扫描将适当的局限在最具体的路径下匹配筛选文件。log_directory 配置的路径会被前置拼接到file_match 配置项上。

+ rescan_interval (int):

在日志轮换备份期间，或日志文件原本在系统中不存在，heka 将会按照该项所配置的时间定时重复检查所需要的日志文件是否出现。默认值为5秒通常比较适用。该配置项单位为毫秒。

+ file_match (string):

通过在该项配置正则表达式，在log_directory 配置的路径下匹配筛选文件。所配置的正则表达式如果没有以$字符结尾则会自动在表达式末尾添加$字符，并且会将log_directory 作为前缀。

提醒：file_match 最好使用单引号来包含字符串，而尽量避免使用双引号，因为双引号要求必须将所有反斜杠转义。例如：'access\.log' 可以达到正确的预期效果，但是"access\.log"就不行，必须写为"access\\.log"才能实现相同结果。

+ priority (list of strings):

当使用持续的日志流时，该项用于日志文件从最老到最新的排序。

+ differentiator (list of strings):

使用多个日志流时，分流器（differentiator）可以配置为字符串集合，这个集合将用于组合日志记录器的名称，并且与file_match 配置项中配置的捕获组相同的部分，生成名称时也会被该捕获组匹配的值替换。

+ translation (hash map of hash maps of ints):

配置为一组可转换的映射表，以便于将匹配的一组值转换为用于排序的整形值。

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
warning - 提醒
rotation - 轮换备份
differentiator - 分流器
```
