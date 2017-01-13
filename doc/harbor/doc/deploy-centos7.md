### 安装包安装 harbor
https://github.com/vmware/harbor/releases
https://github.com/vmware/harbor/blob/master/docs/installation_guide.md

https://github.com/vmware/harbor

需要先安装docker-compose
https://yeasy.gitbooks.io/docker_practice/content/compose/install.html
https://docs.docker.com/compose/install/

sudo su
curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

```
tar -xzvf harbor-installer.tgz
cd harbor
```

修改配置
```
vi harbor.cfg

hostname = 172.28.32.23
```

创建并启动harbor 镜像
```
./prepare
docker-compose up -d
```

查看修改管理员（admin）密码
```
vi config/ui/env

HARBOR_ADMIN_PASSWORD=Harbor12345
```

标记镜像
```
docker tag e4d93b2f809b 172.28.32.23/public/harbor-ui:0.3.5
docker tag d903ee97d5f6 172.28.32.23/public/harbor-jobservice:0.3.5
docker tag dffe9b60925c 172.28.32.23/public/harbor-log:0.3.5
docker tag c00153b6501a 172.28.32.23/public/harbor-db:0.3.5
docker tag c6c14b3960bd 172.28.32.23/public/registry:2.5.0
docker tag 7e156d496c9f 172.28.32.23/public/nginx:1.9.0
```

登陆并上传镜像
```
需要登录
docker login 172.28.32.23
docker push [ip]/[登录账户拥有权限的Project/仓库名]/[镜像名]:[标签/tag]

docker push 172.28.32.23/public/harbor-ui:0.3.5
docker push 172.28.32.23/public/harbor-jobservice:0.3.5
docker push 172.28.32.23/public/harbor-log:0.3.5
docker push 172.28.32.23/public/harbor-db:0.3.5
docker push 172.28.32.23/public/registry:2.5.0
docker push 172.28.32.23/public/nginx:1.9.0
```

重新安装docker-engine 无法启动(Docker version 1.12.1, build 23cf638)，报错
```
Failed to start docker.service: Unit docker.socket failed to load: No such file or directory.
```
解决参考：https://github.com/docker/docker/issues/25098
```
wget https://raw.githubusercontent.com/docker/docker/master/contrib/init/systemd/docker.socket -O /usr/lib/systemd/system/docker.socket
systemctl daemon-reload
systemctl start docker.socket
systemctl start docker
```

```
vi /etc/sysconfig/docker # vi /etc/default/docker
vi /usr/lib/systemd/system/docker.service
vi /etc/systemd/system/docker.service

docker exec -it harbor035_proxy_1 /bin/bash
```

```
docker rm harbor035_jobservice_1
docker rm harbor035_log_1
docker rm harbor035_proxy_1
docker rm harbor035_ui_1
docker rm harbor035_mysql_1
docker rm harbor035_registry_1
```

Trouble Shooting ====================================
1-----------------------
CentOS-7-x86_64-Minimal-1511.iso
Docker version 1.10.3, build 9419b24-unsupported
docker-compose version 1.8.0, build f3628c7
环境下镜像全部下载后无法正常启动，唯一能够启动的是harbor_log_1 容器。
并且登入容器中，root账户没有 /var/log/docker 的任何操作权限。
宿主系统下 /var/log/harbor 目录 root权限可以操作，但是没有任何日志。
替换日志服务后，接收到的日志仍然存在文件系统权限问题。
禁用SELinux：
参考：http://linux.it.net.cn/CentOS/fast/2015/0618/15775.html
vi /etc/selinux/config
设置SELINUX=disabled
2-----------------------
docker push 时默认使用了https
vi /etc/sysconfig/docker
选项OPTIONS中添加 --insecure-registry
OPTIONS='--insecure-registry 172.28.109.240 --selinux-enabled --log-driver=journald'
3-----------------------
修改docker.service 配置，但docker 并没有按照配置执行
```
修改配置
vi /usr/lib/systemd/system/docker.service

# ExecStart=/usr/bin/dockerd
ExecStart=/usr/bin/dockerd --insecure-registry 172.28.32.23

查看dockerd 执行进程并没有添加--insecure-registry 配置
ps -ef | grep dockerd

查看docker service 详细信息
systemctl show docker

其中配置文件指向的地址不是/usr/lib/systemd/system/docker.service，而是
FragmentPath=/etc/systemd/system/docker.service

重新修改配置文件
vi /etc/systemd/system/docker.service

停止docker 运行容器，并停止docker 服务：
docker-compose stop
systemctl stop docker

更新配置，并重新启动docker 服务
systemctl daemon-reload
systemctl start docker
```

