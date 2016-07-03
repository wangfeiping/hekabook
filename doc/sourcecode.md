


信号处理

https://github.com/mozilla-services/heka/blob/be1420d226808485a557ad622bb75785cadfa43a/pipeline/pipeline_runner.go

339行至359行为信号处理，处理由运行系统或其他进程向heka 进程发送的信号。

SIGUSR1 输出heka 报表

示例：
```
如果是使用daemon 通过系统服务方式启动的，每个heka 服务会查到两个进程。

ps -ef | grep hekad

root     109954      1  0 Jun24 ?        00:00:00 /usr/local/bin/daemon -nhekad -uroot -F/heka/hekad.pid -o/logdata/daemon-hekad.log -- /heka/bin/hekad -config=/heka/bin/heka.toml
root     109956 109954 10 Jun24 ?        09:52:30 /heka/bin/hekad -config=/heka/bin/heka.toml

需要向 hekad 的进程发送信号，如下：

kill -SIGUSR1 109956

```
