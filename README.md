# hekabook 开源学习手册

### ------ 源码研究，配置管理，插件开发。

### 项目地址

本项目地址

* https://github.com/wangfeiping/hekabook
* https://coding.net/u/wangfeiping/p/hekabook/git

heka项目地址

* https://github.com/mozilla-services/heka

### 安装 heka

官方参考文档：http://hekad.readthedocs.org/en/v0.10.0/

下载安装包：https://github.com/mozilla-services/heka/releases

以 heka-0_10_0-linux-amd64.tar.gz 为例

```
mkdir /apps  
cd /apps  
wget https://github.com/mozilla-services/heka/releases/download/v0.10.0/heka-0_10_0-linux-amd64.tar.gz  
tar -xzvf heka-0_10_0-linux-amd64.tar.gz  
cd heka-0_10_0-linux-amd64/bin  
```

创建 heka.toml 配置文件

```
[TcpInput]
address = ":514"

[UdpInput]
address = ":514"
splitter = "" # 或 "NullSplitter"

[PayloadEncoder]
append_newlines = false

[LogOutput]
message_matcher = "TRUE"
encoder = "PayloadEncoder"
```

