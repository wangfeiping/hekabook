# Heka 非权威指南

Hekabook 开源学习手册：  
源码研究，配置管理，插件开发，发散式学习！

# Git 工作流基本操作

进入工作目录

> cd workspaces/code/github/hekabook/

提交并签入已修改内容

> git commit -a -m '更新文档'  
> git push --set-upstream origin develop  

签回主分支

> git checkout master  

创建临时的hotfix 分支

> git checkout -b hotfix  

修改......

提交hotfix 分支中的修改（不需签入）

> git commit -a -m '更新文档，增加Git 工作流基本操作文档'  

再次签回主分支

> git checkout master  

在主分支中合并hotfix 分支中的修改

> git merge hotfix  

删除临时的hotfix 分支

> git branch -d hotfix  

提交并签入主分支

> git push --set-upstream origin master  

#### [首页](../ "首页")  

#### [快速入门](./getting_started "快速入门")  

#### [插件与配置](./plugins "插件与配置")  

#### 相关工具  

#### 使用Lua开发插件  

#### Mysql Slow Query 日志分析  

#### 编译安装  

#### 使用Go开发插件  

#### 架构分析  

#### 源码分析  

#### 尝试：如何设计一个每秒处理10万条的日志服务？  

#### [Git 工作流基本操作](./git_workflow "Git 工作流基本操作")  

#### 参考

> https://git-scm.com/book/zh/ch3-2.html  

