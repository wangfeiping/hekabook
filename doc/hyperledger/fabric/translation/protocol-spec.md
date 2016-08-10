# hyperledger fabric 文档翻译

# Protocol Specification 协议规范

### 原文

https://github.com/hyperledger/fabric/blob/master/docs/protocol-spec.md

### 前言

本文档是基于行业用例实现权限区块链（permissioned blockchain）的协议规范。本文档不是为了完整的解释如何实现，而是为了描述系统和应用间各部分组件的接口和关系。

### 目标读者

本规范的目标读者包括：  
+ 考虑实现符合本规范的区块链系统的区块链供应商
+ 愿意参与扩展fabric 能力的工具开发者
+ 希望通过应用区块链技术丰富自己应用功能的应用开发者

### 1. 简介

本文档描述了适用于行业用例的区块链实现，包括基本原理、体系架构和协议。

### 1.1 什么是fabric ？

fabric 是一个数字事件的账本，这些数字事件称为事务，由不同的参与者共享，每个参与者在整个系统中只拥有一部分权利。账本只能够在参与者协商一致时进行更新，并且一旦记录，信息永远不能被更改。每一条记录的事件都是与参与者一致同意的证明一起加密并可验证的。

交易是有担保的（secured），私有的（private）和保密的（confidential）。每个参与者使用身份证明注册网络会员服务以获得系统访问权限。交易与派生证书在网络上完全匿名发布，派生证书不会关联到具体的独立参与者。交易内容通过复杂的推导方法加密，以确保只有预定参与者可以查看内容，从而保护商业交易的保密性。

The ledger allows compliance with regulations as ledger entries are auditable in whole or in part. In collaboration with participants, auditors may obtain time-based certificates to allow viewing the ledger and linking transactions to provide an accurate assessment of the operations.

账本允许
在与参与者协作时，审计者可以获得基于时间的证书，以便查看账本与关联的交易，从而提供对业务的准确评估。

fabric 项目是基于区块链技术实现的，比特币就是可以在fabric 之上构建的简单应用。它采用了模块化的体系架构，允许根据本协议规范实现的组件能够即插即用。它是功能强大的容器技术，能够承载任何主流语言对智能合约的开发。利用熟悉和经过验证的技术是fabric 架构的座右铭。

### 1.2 为何使用fabric ？

早期的区块链技术被应用于一些用途，但并不适用于特定行业的需要。为了迎合现代市场的需求，fabric 项目基于以行业为重点的设计，目的在于解决多重和多样的特定行业用例的要求，在解决可伸缩性问题的同时扩展该领域先驱者的研究。fabric 项目提供了在多区块链网络中授权许可访问网络、隐私以及机密的新途径，

### 1.3 术语

下列术语是在本规范的范围内定义的，以便于读者清除和准确的理解本文描述的概念。

+ 交易 - Transaction  
交易（Transaction）是发送给区块链的一个请求，使之能够在账本上执行一个方法。方法是由链码（Chaincode）实现的。

+ 交易者 - Transactor  
交易者（Transactor）是发布交易的实体，例如客户端应用。

+ 账本 - Ledger  
账本（Ledger）是一条加密的相互链接的数据块的序列，包含交易（Transaction）和当前的世界状态（World State）。

+ 世界状态 - World State  
世界状态（World State）是包含已执行交易（Transaction）结果的变量集合。

+ 链码 - Chaincode  
链码（Chaincode）是应用级别的代码（又称智能合约），作为交易（Transaction）的一部分保存在账本（Ledger）中。链码（Chaincode）运行可能修改世界状态（World State）的交易（Transaction）。

+ 验证端 - Validating Peer  
验证端（Validating Peer）是网络中的一个计算机节点，负责一致协商（consensus），验证交易以及维护账本。

+ 非验证端 - Non-validating Peer  
非验证端（Non-validating Peer）是网络中的一个计算机节点，作为代理将交易者（Transactor）与相邻的验证端（Validating Peer）链接。非验证端（Non-validating Peer）不执行交易（Transaction）但是会验证它们。它还会承载运行事件流服务器和REST服务。

+ 权限账本 - Permissioned Ledger  
权限账本（Permissioned Ledger）就是一个区块链网络，每个实体或节点都必须是该网络的成员。匿名节点不被允许链接。

+ 隐私 - Privacy  
隐私（Privacy）是交易者（Transactor）为了在网络中隐藏身份所需要的。当网络成员检查交易（Transaction）时如果没有特殊权限，交易（Transaction）无法被关联到交易者（Transactor）。

+ 保密 - Confidentiality  
保密（Confidentiality）是处理交易内容，使之不能被任何其他非交易相关者访问的能力。

+ 可审计性 - Auditability  
可审计性（Auditability）区块链必须的属性，作为商业用途需要符合规章，以便于监管机构调查交易记录。

2. Fabric

The fabric is made up of the core components described in the subsections below.

2.1 Architecture

The reference architecture is aligned in 3 categories: Membership, Blockchain, and Chaincode services. These categories are logical structures, not a physical depiction of partitioning of components into separate processes, address spaces or (virtual) machines.

Reference architecture

2.1.1 Membership Services

Membership provides services for managing identity, privacy, confidentiality and auditability on the network. In a non-permissioned blockchain, participation does not require authorization and all nodes can equally submit transactions and/or attempt to accumulate them into acceptable blocks, i.e. there are no distinctions of roles. Membership services combine elements of Public Key Infrastructure (PKI) and decentralization/consensus to transform a non-permissioned blockchain into a permissioned blockchain. In the latter, entities register in order to acquire long-term identity credentials (enrollment certificates), and may be distinguished according to entity type. In the case of users, such credentials enable the Transaction Certificate Authority (TCA) to issue pseudonymous credentials. Such credentials, i.e., transaction certificates, are used to authorize submitted transactions. Transaction certificates persist on the blockchain, and enable authorized auditors to cluster otherwise unlinkable transactions.

2.1.2 Blockchain Services

Blockchain services manage the distributed ledger through a peer-to-peer protocol, built on HTTP/2. The data structures are highly optimized to provide the most efficient hash algorithm for maintaining the world state replication. Different consensus (PBFT, Raft, PoW, PoS) may be plugged in and configured per deployment.

2.1.3 Chaincode Services

Chaincode services provides a secured and lightweight way to sandbox the chaincode execution on the validating nodes. The environment is a “locked down” and secured container along with a set of signed base images containing secure OS and chaincode language, runtime and SDK layers for Go, Java, and Node.js. Other languages can be enabled if required.

2.1.4 Events

Validating peers and chaincodes can emit events on the network that applications may listen for and take actions on. There is a set of pre-defined events, and chaincodes can generate custom events. Events are consumed by 1 or more event adapters. Adapters may further deliver events using other vehicles such as Web hooks or Kafka.

2.1.5 Application Programming Interface (API)

The primary interface to the fabric is a REST API and its variations over Swagger 2.0. The API allows applications to register users, query the blockchain, and to issue transactions. There is a set of APIs specifically for chaincode to interact with the stack to execute transactions and query transaction results.

2.1.6 Command Line Interface (CLI)

CLI includes a subset of the REST API to enable developers to quickly test chaincodes or query for status of transactions. CLI is implemented in Golang and operable on multiple OS platforms.

2.2 Topology

A deployment of the fabric can consist of a membership service, many validating peers, non-validating peers, and 1 or more applications. All of these components make up a chain. There can be multiple chains; each one having its own operating parameters and security requirements.

2.2.1 Single Validating Peer

Functionally, a non-validating peer is a subset of a validating peer; that is, every capability on a non-validating peer may be enabled on a validating peer, so the simplest network may consist of a single validating peer node. This configuration is most appropriate for a development environment, where a single validating peer may be started up during the edit-compile-debug cycle.

Single Validating Peer

A single validating peer doesn't require consensus, and by default uses the noops plugin, which executes transactions as they arrive. This gives the developer an immediate feedback during development.

2.2.2 Multiple Validating Peers

Production or test networks should be made up of multiple validating and non-validating peers as necessary. Non-validating peers can take workload off the validating peers, such as handling API requests and processing events.

Multiple Validating Peers

The validating peers form a mesh-network (every validating peer connects to every other validating peer) to disseminate information. A non-validating peer connects to a neighboring validating peer that it is allowed to connect to. Non-validating peers are optional since applications may communicate directly with validating peers.

2.2.3 Multichain

Each network of validating and non-validating peers makes up a chain. Many chains may be created to address different needs, similar to having multiple Web sites, each serving a different purpose.


### 词典

+ permissioned blockchain - 权限区块链
```
参考 -   https://bitcoinmagazine.com/articles/ubs-develop-yet-another-permissioned-blockchain-banks-1441400109  
权限区块链的基础设施不仅比比特币网络“提高了成千倍的效率”，同时能够通过具有验证功能的治理结构确保对攻击的防范。

The DAO 由于被不断攻击，从众筹成功到被迫“解散”仅三个月
```

+ fabric - fabric 项目名暂未翻译
+ ledger - 账本
+ transaction - 交易
+ chaincode - 链码

