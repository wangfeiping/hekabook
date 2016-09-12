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

### 1.1 fabric 是什么？

fabric 是一个数字事件的账本，这些数字事件称为事务，由不同的参与者共享，每个参与者在整个系统中只拥有一部分权利。账本只能够在参与者协商一致时进行更新，并且一旦记录，信息永远不能被更改。每一条记录的事件都是与参与者一致同意的证明一起加密并可验证的。

交易是有安全的（secured），私有的（private）和保密的（confidential）。每个参与者使用身份证明注册网络会员服务以获得系统访问权限。交易与派生证书在网络上完全匿名发布，派生证书不会关联到具体的独立参与者。交易内容通过复杂的推导方法加密，以确保只有预定参与者可以查看内容，从而保护商业交易的保密性。

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

+ 验证点 - Validating Peer  
验证点（Validating Peer）是网络中的一个计算机节点，负责一致协商（consensus），验证交易以及维护账本。

+ 非验证点 - Non-validating Peer  
非验证点（Non-validating Peer）是网络中的一个计算机节点，作为代理将交易者（Transactor）与相邻的验证点（Validating Peer）链接。非验证点（Non-validating Peer）不执行交易（Transaction）但是会验证它们。它还会承载运行事件流服务器和REST服务。

+ 权限账本 - Permissioned Ledger  
权限账本（Permissioned Ledger）就是一个区块链网络，每个实体或节点都必须是该网络的成员。匿名节点不被允许链接。

+ 私密性 - Privacy  
私密性（Privacy）是交易者（Transactor）为了在网络中隐藏身份所需要的。当网络成员检查交易（Transaction）时如果没有特殊权限，交易（Transaction）无法被关联到交易者（Transactor）。

+ 保密性 - Confidentiality  
保密性（Confidentiality）是处理交易内容，使之不能被任何其他非交易相关者访问的能力。

+ 可审计性 - Auditability  
可审计性（Auditability）区块链必须的属性，作为商业用途需要符合规章，以便于监管机构调查交易记录。

### 2. Fabric

fabric 系统由如下介绍的核心组件组成。

### 2.1 体系架构

参照架构主要划分为3类：成员（Membership），区块链（Blockchain），链码（Chaincode）。这几个类别是逻辑结构，而不是描述组件各部分在物理进程、地址空间或（虚拟）机器中的划分。

参照架构/图

### 2.1.1 成员（Membership）服务

成员（Membership）服务提供网络身份标识、私密性（Privacy）、保密性（Confidentiality）以及可审计性（Auditability）的管理。在非权限的区块链网络中，参与不需要授权并且所有节点能够平等的提交交易或尝试积累这些（交易？）为可接受的数据块，即参与角色没有区别。成员（Membership）服务结合PKI（Public Key Infrastructure）以及下发（decentralization）和共识协议（consensus）等元素，将非权限区块链网络转换为权限区块链网络。在后者中，实体通过注册获得长期的身份凭证 （注册证书），并且可以根据实体类型进行区分。对于用户来说，这些证书具有TCA（Transaction Certificate Authority/交易凭证权限）可以发布匿名凭证这些凭证，即交易凭证，被用于授权提交交易。交易凭证保存在区块链网络中，能够使已授权的审计者访问集群中其他非关联的交易。

### 2.1.2 区块链（Blockchain）服务

区块链（Blockchain）服务通过点对点协议管理分布式账本，基于HTTP/2。数据结构经过高度的优化并提供了高效的哈希算法用于维护世界状态（World State）的复制。不同的共识协议（PBFT, Raft, PoW, PoS）可以在每一次部署中配置选择和接入。

### 2.1.3 链码（Chaincode）服务

链码（Chaincode）服务提供安全和轻量的方式在验证点（Validating Peer）的沙盒中执行链码。这个执行环境是一种“锁定（隔离的？）”的、安全的容器，包括一系列的基础镜像，这些镜像包含安全系统与链码的实现语言，运行时环境和开发语言的SDK（如：Go，Java以及Node.js）。其他语言如果需要也可以配置安装。

### 2.1.4 事件（Events）

验证点（Validating peer）和链码能够发送可被网络应用监听和执行的事件。有一系列的预定义事件，并且链码（Chaincode）能够生成自定义事件。事件可被一个或多个事件适配器消费。适配器可以通过其他工具将这些事件进一步分发（如：Web hooks 或Kafka）。

### 2.1.5 API (Application Programming Interface)

fabric 的主要接口是RESTful API 并且通过Swagger 2.0 更新修改。API 允许应用注册用户，查询区块链（Blockchain），以及发布交易。API 的一系列接口是专门为链码（Chaincode）提供的，以便于链码（Chaincode）与？（the stack）进行交互以执行交易（Transaction）并查询交易（Transaction）结果。

### 2.1.6 CLI (Command Line Interface)

CLI 包含REST API 的一个子集使开发者能够快速的测试链码（Chaincode）或查询交易（Transaction）的状态。CLI 是由Golang 语言开发，可在多个系统平台中运行操作。

### 2.2 拓扑结构 - Topology

fabric 部署包括一个成员（Membership）服务，多个验证点（Validating peer）和非验证点（Non-validating peer），以及一个或多个应用。所有这些组件组成一条链；也可以是多条链，每条链都有其自己的运行参数和安全要求。

### 2.2.1 单验证点（Validating Peer）

功能上，非验证点（Non-validating peer）是验证点（Validating peer）的子集；这就是说，非验证点(Non-validating peer)拥有的能力验证点（Validating peer）应该也拥有，因此最简单的网络可以由一个单独的验证点节点组成。这种配置更接近于开发环境。

单验证点（Validating Peer）/图

单点验证点（Validating peer）不需要共识协议，并且默认使用？（noops）插件，该插件可以在接收到交易后即可运行交易。这使开发者可以在开发阶段立即得到运行结果反馈。

### 2.2.2 多验证点（Validating Peer）

生产或测试网络应该由多个验证点（Validating Peer）和非验证点（Non-validating peer）组成。非验证点（Non-validating peer）能够分担验证点（Validating Peer）的压力，例如处理API 请求和事件。

多验证点（Validating Peer）/图

验证点（Validating Peer）通过组成的网状网络（每个验证点都与其他验证点相连）来传输信息。非验证点（Non-validating peer）链接相邻的允许其链接的验证点（Validating Peer）。非验证点（Non-validating peer）是可选的因为应用可以直接访问验证点（Validating Peer）。

### 2.2.3 多链（Multichain）

每个由验证点和非验证点组成的网络形成一条链。多条链可以针对不同的需求，类似于多个网站，每个网站都可以服务于一个不同的目的。

### 3. 协议

fabric 的点对点通信是基于gRPC 的，gRPC 允许基于流的双向消息传输。gRPC 使用协议缓存（Protocol Buffer）序列化数据结构以便在端点之间传输数据。协议缓存（Protocol Buffer）采用语言中立和平台中立的可扩展机制进行结构数据的序列化。数据结构、消息以及服务使用proto3 语言进行描述。

gRPC http://www.grpc.io/docs/

Protocol Buffer https://developers.google.com/protocol-buffers/

proto3 https://developers.google.com/protocol-buffers/docs/proto3

### 3.1 消息 - Message

节点之间传输的消息通过消息原型结构（Message proto structure）定义，可分为4个类型：（Discovery）、（Transaction）、（Synchronization）、（Consensus）。每个类型都可以定义更多子类型并在消息体中（payload）嵌套使用。

# 注意：此处暂时忽略，内容主要是描述具体消息结构格式。
```
消息原型结构（Message proto structure） ，定义消息的结构格式，但并不是具体传输的消息内容，可与后面具体的消息内容对照参考：
message ChaincodeSpec {
    enum Type {
        UNDEFINED = 0;
        GOLANG = 1;
        NODE = 2;
    }
    Type type = 1;
    ChaincodeID chaincodeID = 2;
    ChaincodeInput ctorMsg = 3;
    int32 timeout = 4;
    string secureContext = 5;
    ConfidentialityLevel confidentialityLevel = 6;
    bytes metadata = 7;
}

message ChaincodeID {
    string path = 1;
    string name = 2;
}

message ChaincodeInput {
    string function = 1;
    repeated string args  = 2;
}

具体传输的消息内容：
POST host:port/chaincode

{
  "jsonrpc": "2.0",
  "method": "deploy",
  "params": {
    "type": "GOLANG",
    "chaincodeID":{
        "path":"github.com/hyperledger/fabic/examples/chaincode/go/chaincode_example02"
    },
    "ctorMsg": {
        "function":"init",
        "args":["a", "1000", "b", "2000"]
    }
  },
  "id": "1"  
}
```

### 3.2 账本（Ledger）

### 3.3 链码（Chaincode）

### 3.4 可插拔的共识协议框架（Pluggable Consensus Framework）

### 3.5 事件（Events）

### 4. 安全（Security）

本节讨论下图所示的设置。该系统由如下的实体组成：成员管理设施，即负责确认用户身份的一组实体（使用系统支持的任意形式的身份认证方式，例如：信用卡，身份证），并为该用户打开账号使该用户能够在fabric 中注册、发布必要的证书以成功创建交易并部署和调用链码（Chaincode）。

架构图/图

+ 端点，被分类为验证点（Validating peer）和非验证点（Non-validating peer）。验证点（也叫验证者）订阅并处理（验证有效性、执行、添加到区块链）提交给网络的用户消息（交易/Transaction）。非验证点（也叫端点）接收以用户名义发出的交易（Transaction），并在一些基本的有效性检查之后，会将交易转发到相邻的验证点（Validating peer）。端点维护区块链最新的副本，？？？但是与验证者产生矛盾时，端点不会执行交易（这个过程也叫做交易验证）。？？？
    
+ 系统的终端用户，已经注册到成员服务中，在出示了系统所确认其身份的所有权之后，将获得证书可用于安装到客户端软件或直接提交交易给系统。
    
+ 客户端软件，软件需要安装在客户端以便能够完成成员（Membership）服务的注册以及向系统提交交易（Transaction）。

+ 在线钱包，是用户信任的实体，在网络中全权负责维护用户的证书以及提交交易。在线钱包是独立的客户端软件（通常是轻量的），在客户端只需要验证其自身及其所发给在线钱包的请求。实际情形中（同一个）端点也可以为多个用户访问和使用在线钱包，但与在线钱包的会话（Session）中不同用户的安全性是完全隔离的。

想要使用fabric 的用户，在成员管理中打开账户（如前面章节所术证明身份所有权），链码创建者（开发者）使用客户端软件为自己在区块链网络中（提交部署交易/deployment transaction）公布新的链码（Chaincode）。这样的交易首先被端点或验证者接收，之后会分发给整个网络的验证者，这个交易会被执行并在区块链网络中找到自己的位置。用户也可以使用调用交易（invocation transaction）调用一个已经部署的链码的方法。

下一节总结了系统安全需求的商业目标。将会介绍安全组件及其几本操作以及展示该设计如何满足安全需求。

### 4.1 商业安全需求

本节介绍与fabric 环境相关的商业安全需求。身份与角色管理的结合。

为了充分支持真实的商业应用不仅要确保？？？加密的持续性（cryptographic continuity）？？？。？？？A workable B2B system must consequently move towards addressing proven/demonstrated identities or other attributes relevant to conducting business.？？？商业交易与消费者与商业机构交互时需要明确的对应到账户。商业合约通常要求明确关联特定机构和/或交易方的特定财产。可追溯（Accountability）和不可伪造（Non-frameability）是身份管理成为这类系统重要组件的两个原因。

可追溯意味着系统用户、个人或公司的过失行为可被追溯并为其行为负责。在许多情况下，B2B系统的成员会被要求使用他们的真实身份（某种形式）参与到系统中，作为可追溯的一种保障方式。可追溯和不可伪造都是B2B系统基本的安全需求并且相互密切关联。B2B系统应保障系统中的诚实用户不会为被假冒发起的交易负责。

此外B2B系统应该可更新和灵活以便符合参与者角色和从属关系的变化。

交易私密性（Transactional privacy）

B2B的关系中对交易私密性有强需求，即允许终端用户控制系统中交互和共享信息的程度。例如，一个公司正在做的交易要求不能被其他公司或合作者在没有被授权的情况下看到相关机密信息。

在fabric 中，交易私密性是在尊重非授权用户的前提下通过实现两个特性来提供的：

+ 匿名交易，交易的所有者如果在一个匿名集合中时是隐藏的，在fabric 中这个集合就是一个用户集合。

+ 交易的非关联性，同一个用户的交易之间不应建立关联。

从文中可以很清楚的看出来，非授权用户可以是系统外的任何一个人，或是一部分用户。

交易私密性是与B2B系统成员间合约内容的保密性密切相关的，两个或多个成员之间的合同协议内容的保密性，与任何身份验证机制的匿名和非关联性一样，应在交易中得到应有的重视。

协调交易私密性与身份管理

为了协调身份管理与交易私密性，使竞争的机构能够有效地在普通区块链上交易（机构内和机构间交易），方法是，如下︰

+ 1、增加证书到交易中实现权限区块链

+ 2、使用两级系统：

    i. （相对）静态注册证书（ECerts），通过登记注册证书颁发机构（CA）获得。

    ii. 真实但匿名的代表注册用户的的交易证书（TCerts），通过交易证书颁发机构（CA）获得。

+ 3、提供机制对未授权的系统成员隐藏交易内容。

审计支持

商业系统有时会受到审计。审计者需要检查某一具体交易或一组特定的交易，系统特定用户的行为，或系统本身的运行情况。因此，这种（审计）能力应该在所有交易系统中通过商业伙伴之间合同协定的方式提供。

### 4.2 成员服务中的用户私密信息

成员服务由网络中共同管理用户身份和私密信息的多个实体组成。这些服务验证用户身份，这些服务验证用户身份，将用户注册到系统中，并提供所有所需的证书，以使用户成为被授权的参与者进而能够创建和/或调用交易。PKI是基于公钥加密的框架，以确保在保证公网数据交换安全的同时可以确认对方的身份。PKI管理秘钥和数字证书的生成，分发和吊销。数字证书用于创建用户证书和签名消息。携带证书的签名消息可以确保消息不会被篡改。通常PKI包括证书颁发机构（CA），注册机构（RA），证书数据库和证书存储。RA负责验证用户身份以及审查数据、证书或其他凭证的合法性，以支持用户进一步请求反应其身份或其他属性的证书。CA直接或间接由根CA认证，会接收RA的数据信息并根据其信息向特定用户发布数字证书。或者，在与用户通信或为了提高效率时，RA可以被归入CA。成员服务由下图所示的实例组成。介绍了完整的PKI体系，加强B2B系统的健壮性（？？？超过比特币？？？）。

图1/图

根CA（Root Certificate Authority）：代表PKI体系的信任基础。数字证书的验证需要沿着信任链进行验证。根CA是PKI体系最顶端的CA。

RA：可以确认想要加入权限区块链的用户的有效性和身份。负责与用户带外通信（out-of-band communication）验证用户身份与角色。为在根上注册和获取信息创建登记凭证。

ECA（注册证书颁发机构/Enrollment Certificate Authority）：负责在验证了用户提供的登记凭证之后发布注册证书（ECerts）。

TCA（交易证书颁发机构/Transaction Certificate Authority）：负责在验证了用户提供的注册凭证之后发布交易证书（TCerts）。

TLS-CA（TLS证书颁发机构/TLS Certificate Authority）：负责发布TLS证书与凭证允许用户使用其网络。TLS-CA验证用户提供的凭证或证据，以此检验TLS证书签发时包含了相关用户的指定信息。

在本规范中，成员服务通过 PKI颁发下列相关联的证书：

* 注册证书（ECerts） - 注册证书是长期证书，为所有角色发布，即用户、非验证点、验证点。对于用户，提交交易以候选等待被纳入区块链并且拥有TCerts（之后讨论），有两种结构和模型：

    + 模型A：？？？注册证书（ECerts）包含拥有者的身份信息和注册ID，并可被用于实名认证的实体请求交易证书（TCerts）与交易。注册证书包含两对密钥的公共部分 - 签名密钥对和加密/密钥协议密钥对。注册证书（ECerts）可以被所有角色访问。？？？ Model A: ECerts contain the identity/enrollmentID of their owner and can be used to offer only nominal entity-authentication for TCert requests and/or within transactions. They contain the public part of two key pairs – a signature key-pair and an encryption/key agreement key-pair. ECerts are accessible to everyone.

    + 模型B：？？？注册证书（ECerts）包含拥有者的身份信息和注册ID，并可被用于实名认证的实体请求交易证书（TCerts）。注册证书包含签名验证公钥。注册证书最好只能由TCA和审计者访问，而对交易是不可见的，因此（不像交易证书）签名密钥对在这一级别不充当不可抵赖的角色。？？？ Model B: ECerts contain the identity/enrollmentID of their owner and can be used to offer only nominal entity-authentication for TCert requests. They contain the public part of a signature key-pair, i.e., a signature verification public key. ECerts are preferably accessible to only TCA and auditors, as relying parties. They are invisible to transactions, and thus (unlike TCerts) their signature key pairs do not play a non-repudiation role at that level.

* 交易证书（TCerts） - 交易证书是短期证书，为每一个交易发布。交易证书由授权的用户请求TCA（交易证书颁发机构）发布。交易证书安全的授权交易，并可配置为不暴露参与交易方的身份或选择性的透露身份/注册ID信息。交易证书包含签名密钥对的公共部分，并可配置为也包含密钥协议密钥对的公共部分。交易证书仅发布给用户，它们唯一关联拥有者 - 也可以配置为此关联只会被TCA访问（并且可以授权给审计者）。交易证书可以配置为不携带用户的身份信息，这使用户不及可以匿名的参与系统也可以保护交易的关联性。

然而，可审计性和可追溯性需要TCA能够检索给定身份的交易证书，或检索特定交易证书的拥有者。交易证书部署和调用交易的细节需查看 4.3节 交易安全在基础设施级别提供。

交易证书可包含加密或密钥协议公公共密钥 （以及数字签名验证公钥）。如果交易证书已经包含这些信息，那么注册证书无需也包含加密或密钥协议的公共密钥。

TCA生成密钥协议公共密钥的方法与其生成签名验证公共密钥的方法相同，？？？但是使用TCertIndex + 1的索引值而不是TCertIndex，TCertIndex被TCA隐藏在交易证书中其拥有者可以恢复。？？？

交易证书 (TCert) 的结构如下所示：

+ TCertID – transaction certificate ID (preferably generated by TCA randomly in order to avoid unintended linkability via the Hidden Enrollment ID field).

+ Hidden Enrollment ID: AES_EncryptK(enrollmentID), where key K = [HMAC(Pre-K, TCertID)]256-bit truncation and where three distinct key distribution scenarios for Pre-K are defined below as (a), (b) and (c).

+ Hidden Private Keys Extraction: AES_EncryptTCertOwner_EncryptKey(TCertIndex || known padding/parity check vector) where || denotes concatenation, and where each batch has a unique (per batch) time-stamp/random offset that is added to a counter (initialized at 1 in this implementation) in order to generate TCertIndex. The counter can be incremented by 2 each time in order to accommodate generation by the TCA of the public keys and recovery by the TCert owner of the private keys of both types, i.e., signature key pairs and key agreement key pairs.

+ Sign Verification Public Key – TCert signature verification public key.

+ Key Agreement Public Key – TCert key agreement public key.

+ Validity period – the time window during which the transaction certificate can be used for the outer/external signature of a transaction.

至少有三个方法配置密钥分发来隐藏注册 ID：

+ (a) Pre-K is distributed during enrollment to user clients, peers and auditors, and is available to the TCA and authorized auditors. It may, for example, be derived from Kchain (described subsequently in this specification) or be independent of key(s) used for chaincode confidentiality.

+ (b) Pre-K is available to validators, the TCA and authorized auditors. K is made available by a validator to a user (under TLS) in response to a successful query transaction. The query transaction can have the same format as the invocation transaction. Corresponding to Example 1 below, the querying user would learn the enrollmentID of the user who created the Deployment Transaction if the querying user owns one of the TCerts in the ACL of the Deployment Transaction. Corresponding to Example 2 below, the querying user would learn the enrollmentID of the user who created the Deployment Transaction if the enrollmentID of the TCert used to query matches one of the affiliations/roles in the Access Control field of the Deployment Transaction.

Example 1:

Example 1

Example 2:

Example 2

+ (c) Pre-K is available to the TCA and authorized auditors. The TCert-specific K can be distributed the TCert owner (under TLS) along with the TCert, for each TCert in the batch. This enables targeted release by the TCert owner of K (and thus trusted notification of the TCert owner’s enrollmentID). Such targeted release can use key agreement public keys of the intended recipients and/or PKchain where SKchain is available to validators as described subsequently in this specification. Such targeted release to other contract participants can be incorporated into a transaction or done out-of-band.

如果交易证书与注册证书模型 A结合使用，那么使用(c)方法K不分发给交易证书用有者也可以，并且交易证书的密钥协议公共密钥字段也不是必须的。

TCA会批量返回交易证书，每一批证书会包含KeyDF_Key（密钥派生功能密钥/Key-Derivation-Function Key），该密钥不会每个交易证书都配发，但会配发给每批交易证书并一起发送给客户端（使用TLS）。？？？KeyDF_Key允许交易证书拥有者派生TCertOwner_EncryptKey 使TCertIndex 能够从AES_EncryptTCertOwner_EncryptKey（TCertIndex || known padding/parity check vector）恢复。？？？

TLS-Certs（TLS 证书/TLS-Certificate） - TLS 证书是用于系统/组件对系统/组件间通信的证书。他们携带其所有者的身份，并用于网络级别的安全性。

This implementation of membership services provides the following basic functionality: there is no expiration/revocation of ECerts; expiration of TCerts is provided via the validity period time window; there is no revocation of TCerts. The ECA, TCA, and TLS CA certificates are self-signed, where the TLS CA is provisioned as a trust anchor.

成员服务实现了以下基本功能︰ 没有过期/吊销的注册证书；通过有效性时间窗口提供的交易证书过期功能；交易证书没有撤销功能。ECA、 TCA 和 TLS CA 证书是自签名的，TLS CA为信任基础。

### 4.2.1 User/Client Enrollment Process

The next figure has a high-level description of the user enrollment process. It has an offline and an online phase.

Registration

Offline Process: in Step 1, each user/non-validating peer/validating peer has to present strong identification credentials (proof of ID) to a Registration Authority (RA) offline. This has to be done out-of-band to provide the evidence needed by the RA to create (and store) an account for the user. In Step 2, the RA returns the associated username/password and trust anchor (TLS-CA Cert in this implementation) to the user. If the user has access to a local client then this is one way the client can be securely provisioned with the TLS-CA certificate as trust anchor.

Online Phase: In Step 3, the user connects to the client to request to be enrolled in the system. The user sends his username and password to the client. On behalf of the user, the client sends the request to the PKI framework, Step 4, and receives a package, Step 5, containing several certificates, some of which should correspond to private/secret keys held by the client. Once the client verifies that the all the crypto material in the package is correct/valid, it stores the certificates in local storage and notifies the user. At this point the user enrollment has been completed.

Figure 4

Figure 4 shows a detailed description of the enrollment process. The PKI framework has the following entities – RA, ECA, TCA and TLS-CA. After Step 1, the RA calls the function “AddEntry” to enter the (username/password) in its database. At this point the user has been formally registered into the system database. The client needs the TLS-CA certificate (as trust anchor) to verify that the TLS handshake is set up appropriately with the server. In Step 4, the client sends the registration request to the ECA along with its enrollment public key and additional identity information such as username and password (under the TLS record layer protocol). The ECA verifies that such user really exists in the database. Once it establishes this assurance the user has the right to submit his/her enrollment public key and the ECA will certify it. This enrollment information is of a one-time use. The ECA updates the database marking that this registration request information (username/password) cannot be used again. The ECA constructs, signs and sends back to the client an enrollment certificate (ECert) that contains the user’s enrollment public key (Step 5). It also sends the ECA Certificate (ECA-Cert) needed in future steps (client will need to prove to the TCA that his/her ECert was created by the proper ECA). (Although the ECA-Cert is self-signed in the initial implementation, the TCA and TLS-CA and ECA are co-located.) The client verifies, in Step 6, that the public key inside the ECert is the one originally submitted by the client (i.e. that the ECA is not cheating). It also verifies that all the expected information within the ECert is present and properly formed.

Similarly, In Step 7, the client sends a registration request to the TLS-CA along with its public key and identity information. The TLS-CA verifies that such user is in the database. The TLS-CA generates, and signs a TLS-Cert that contains the user’s TLS public key (Step 8). TLS-CA sends the TLS-Cert and its certificate (TLS-CA Cert). Step 9 is analogous to Step 6, the client verifies that the public key inside the TLS Cert is the one originally submitted by the client and that the information in the TLS Cert is complete and properly formed. In Step 10, the client saves all certificates in local storage for both certificates. At this point the user enrollment has been completed.

In this implementation the enrollment process for validators is the same as that for peers. However, it is possible that a different implementation would have validators enroll directly through an on-line process.

Figure 5 Figure 6

Client: Request for TCerts batch needs to include (in addition to count), ECert and signature of request using ECert private key (where Ecert private key is pulled from Local Storage).

TCA generates TCerts for batch: Generates key derivation function key, KeyDF_Key, as HMAC(TCA_KDF_Key, EnrollPub_Key). Generates each TCert public key (using TCertPub_Key = EnrollPub_Key + ExpansionValue G, where 384-bit ExpansionValue = HMAC(Expansion_Key, TCertIndex) and 384-bit Expansion_Key = HMAC(KeyDF_Key, “2”)). Generates each AES_EncryptTCertOwner_EncryptKey(TCertIndex || known padding/parity check vector), where || denotes concatenation and where TCertOwner_EncryptKey is derived as [HMAC(KeyDF_Key, “1”)]256-bit truncation.

Client: Deriving TCert private key from a TCert in order to be able to deploy or invoke or query: KeyDF_Key and ECert private key need to be pulled from Local Storage. KeyDF_Key is used to derive TCertOwner_EncryptKey as [HMAC(KeyDF_Key, “1”)]256-bit truncation; then TCertOwner_EncryptKey is used to decrypt the TCert field AES_EncryptTCertOwner_EncryptKey(TCertIndex || known padding/parity check vector); then TCertIndex is used to derive TCert private key: TCertPriv_Key = (EnrollPriv_Key + ExpansionValue) modulo n, where 384-bit ExpansionValue = HMAC(Expansion_Key, TCertIndex) and 384-bit Expansion_Key = HMAC(KeyDF_Key, “2”).
4.2.2 Expiration and revocation of certificates

It is practical to support expiration of transaction certificates. The time window during which a transaction certificate can be used is expressed by a ‘validity period’ field. The challenge regarding support of expiration lies in the distributed nature of the system. That is, all validating entities must share the same information; i.e. be consistent with respect to the expiration of the validity period associated with the transactions to be executed and validated. To guarantee that the expiration of validity periods is done in a consistent manner across all validators, the concept of validity period identifier is introduced. This identifier acts as a logical clock enabling the system to uniquely identify a validity period. At genesis time the “current validity period” of the chain gets initialized by the TCA. It is essential that this validity period identifier is given monotonically increasing values over time, such that it imposes a total order among validity periods.

A special type of transactions, system transactions, and the validity period identified are used together to announce the expiration of a validity period to the Blockchain. System transactions refer to contracts that have been defined in the genesis block and are part of the infrastructure. The validity period identified is updated periodically by the TCA invoking a system chaincode. Note that only the TCA should be allowed to update the validity period. The TCA sets the validity period for each transaction certificate by setting the appropriate integer values in the following two fields that define a range: ‘not-before’ and ‘not-after’ fields.

TCert Expiration: At the time of processing a TCert, validators read from the state table associated with the ledger the value of ‘current validity period’ to check if the outer certificate associated with the transaction being evaluated is currently valid. That is, the current value in the state table has to be within the range defined by TCert sub-fields ‘not-before’ and ‘not-after’. If this is the case, the validator continues processing the transaction. In the case that the current value is not within range, the TCert has expired or is not yet valid and the validator should stop processing the transaction.

ECert Expiration: Enrollment certificates have different validity period length(s) than those in transaction certificates.

Revocation is supported in the form of Certificate Revocation Lists (CRLs). CRLs identify revoked certificates. Changes to the CRLs, incremental differences, are announced through the Blockchain.

### 4.3 Transaction security offerings at the infrastructure level

Transactions in the fabric are user-messages submitted to be included in the ledger. As discussed in previous sections, these messages have a specific structure, and enable users to deploy new chaincodes, invoke existing chaincodes, or query the state of existing chaincodes. Therefore, the way transactions are formed, announced and processed plays an important role to the privacy and security offerings of the entire system.

On one hand our membership service provides the means to authenticate transactions as having originated by valid users of the system, to disassociate transactions with user identities, but while efficiently tracing the transactions a particular individual under certain conditions (law enforcement, auditing). In other words, membership services offer to transactions authentication mechanisms that marry user-privacy with accountability and non-repudiation.

On the other hand, membership services alone cannot offer full privacy of user-activities within the fabric. First of all, for privacy provisions offered by the fabric to be complete, privacy-preserving authentication mechanisms need to be accompanied by transaction confidentiality. This becomes clear if one considers that the content of a chaincode, may leak information on who may have created it, and thus break the privacy of that chaincode's creator. The first subsection discusses transaction confidentiality.

Enforcing access control for the invocation of chaincode is an important security requirement. The fabric exposes to the application (e.g., chaincode creator) the means for the application to perform its own invocation access control, while leveraging the fabric's membership services. Section 4.4 elaborates on this.

Replay attacks is another crucial aspect of the security of the chaincode, as a malicious user may copy a transaction that was added to the Blockchain in the past, and replay it in the network to distort its operation. This is the topic of Section 4.3.3.

The rest of this Section presents an overview of how security mechanisms in the infrastructure are incorporated in the transactions' lifecycle, and details each security mechanism separately.

### 4.3.1 Security Lifecycle of Transactions

Transactions are created on the client side. The client can be either plain client, or a more specialized application, i.e., piece of software that handles (server) or invokes (client) specific chaincodes through the blockchain. Such applications are built on top of the platform (client) and are detailed in Section 4.4.

Developers of new chaincodes create a new deploy transaction by passing to the fabric infrastructure:

    the confidentiality/security version or type they want the transaction to conform with,
    the set of users who wish to be given access to parts of the chaincode and a proper representation of their (read) access rights <!-- (read-access code/state/activity, invocation-access) -->
    the chaincode specification,
    code metadata, containing information that should be passed to the chaincode at the time of its execution (e.g., configuration parameters), and
    transaction metadata, that is attached to the transaction structure, and is only used by the application that deployed the chaincode.

Invoke and query transactions corresponding to chaincodes with confidentiality restrictions are created using a similar approach. The transactor provides the identifier of the chaincode to be executed, the name of the function to be invoked and its arguments. Optionally, the invoker can pass to the transaction creation function, code invocation metadata, that will be provided to the chaincode at the time of its execution. Transaction metadata is another field that the application of the invoker or the invoker himself can leverage for their own purposes.

Finally transactions at the client side, are signed by a certificate of their creator and released to the network of validators. Validators receive the confidential transactions, and pass them through the following phases:

    pre-validation phase, where validators validate the transaction certificate against the accepted root certificate authority, verify transaction certificate signature included in the transaction (statically), and check whether the transaction is a replay (see, later section for details on replay attack protection).
    consensus phase, where the validators add this transaction to the total order of transactions (ultimately included in the ledger)
    pre-execution phase, where validators verify the validity of the transaction / enrollment certificate against the current validity period, decrypt the transaction (if the transaction is encrypted), and check that the transaction's plaintext is correctly formed(e.g., invocation access control is respected, included TCerts are correctly formed); mini replay-attack check is also performed here within the transactions of the currently processed block.
    execution phase, where the (decrypted) chaincode is passed to a container, along with the associated code metadata, and is executed
    commit phase, where (encrypted) updates of that chaincodes state is committed to the ledger with the transaction itself.

4.3.2 Transaction confidentiality

Transaction confidentiality requires that under the request of the developer, the plain-text of a chaincode, i.e., code, description, is not accessible or inferable (assuming a computational attacker) by any unauthorized entities(i.e., user or peer not authorized by the developer). For the latter, it is important that for chaincodes with confidentiality requirements the content of both deploy and invoke transactions remains concealed. In the same spirit, non-authorized parties, should not be able to associate invocations (invoke transactions) of a chaincode to the chaincode itself (deploy transaction) or these invocations to each other.

Additional requirements for any candidate solution is that it respects and supports the privacy and security provisions of the underlying membership service. In addition, it should not prevent the enforcement of any invocation access control of the chain-code functions in the fabric, or the implementation of enforcement of access-control mechanisms on the application (See Subsection 4.4).

In the following is provided the specification of transaction confidentiality mechanisms at the granularity of users. The last subsection provides some guidelines on how to extend this functionality at the level of validators. Information on the features supported in current release and its security provisions, you can find in Section 4.7.

The goal is to achieve a design that will allow for granting or restricting access to an entity to any subset of the following parts of a chain-code: 1. chaincode content, i.e., complete (source) code of the chaincode,

    chaincode function headers, i.e., the prototypes of the functions included in a chaincode, <!--access control lists, --> <!--and their respective list of (anonymous) identifiers of users who should be able to invoke each function-->
    chaincode [invocations &] state, i.e., successive updates to the state of a specific chaincode, when one or more functions of its are invoked
    all the above

Notice, that this design offers the application the capability to leverage the fabric's membership service infrastructure and its public key infrastructure to build their own access control policies and enforcement mechanisms.

### 4.3.2.1 Confidentiality against users

To support fine-grained confidentiality control, i.e., restrict read-access to the plain-text of a chaincode to a subset of users that the chaincode creator defines, a chain is bound to a single long-term encryption key-pair (PKchain, SKchain). Though initially this key-pair is to be stored and maintained by each chain's PKI, in later releases, however, this restriction will be moved away, as chains (and the associated key-pairs) can be triggered through the Blockchain by any user with special (admin) privileges (See, Section 4.3.2.2).

Setup. At enrollment phase, users obtain (as before) an enrollment certificate, denoted by Certui for user ui, while each validator vj obtain its enrollment certificate denoted by Certvj. Enrollment would grant users and validators the following credentials:

    Users:

    a. claim and grant themselves signing key-pair (spku, ssku),

    b. claim and grant themselves encryption key-pair (epku, esku),

    c. obtain the encryption (public) key of the chain PKchain

    Validators:

    a. claim and grant themselves signing key-pair (spkv, sskv),

    b. claim and grant themselves an encryption key-pair (epkv, eskv),

    c. obtain the decryption (secret) key of the chain SKchain

Thus, enrollment certificates contain the public part of two key-pairs:

    one signature key-pair [denoted by (spkvj,sskvj) for validators and by (spkui, sskui) for users], and
    an encryption key-pair [denoted by (epkvj,eskvj) for validators and (epkui, eskui) for users]

Chain, validator and user enrollment public keys are accessible to everyone.

In addition to enrollment certificates, users who wish to anonymously participate in transactions issue transaction certificates. For simplicity transaction certificates of a user ui are denoted by TCertui. Transaction certificates include the public part of a signature key-pair denoted by
(tpkui,tskui).

The following section provides a high level description of how transaction format accommodates read-access restrictions at the granularity of users.

Structure of deploy transaction. The following figure depicts the structure of a typical deploy transaction with confidentiality enabled.

FirstRelease-deploy

One can notice that a deployment transaction consists of several sections:

    Section general-info: contains the administration details of the transaction, i.e., which chain this transaction corresponds to (chained), the type of transaction (that is set to ''deplTrans''), the version number of confidentiality policy implemented, its creator identifier (expressed by means of transaction certificate TCert of enrollment certificate Cert), and a Nonce, that facilitates primarily replay-attack resistance techniques.
    Section code-info: contains information on the chain-code source code, and function headers. As shown in the figure below, there is a symmetric key used for the source-code of the chaincode (KC), and another symmetric key used for the function prototypes (KH). A signature of the creator of the chaincode is included on the plain-text code such that the latter cannot be detached from the transaction and replayed by another party.
    Section chain-validators: where appropriate key material is passed to the validators for the latter to be able to (i) decrypt the chain-code source (KC), (ii) decrypt the headers, and (iii) encrypt the state when the chain-code has been invoked accordingly(KS). In particular, the chain-code creator generates an encryption key-pair for the chain-code it deploys (PKC, SKC). It then uses PKC to encrypt all the keys associated to the chain-code: [(''code'',KC) ,(''headr'',KH),(''code-state'',KS), SigTCertuc(*)]PKc, and passes the secret key SKC to the validators using the chain-specific public key: [(''chaincode'',SKC), SigTCertuc(*)]PKchain.

    Section contract-users: where the public encryption keys of the contract users, i.e., users who are given read-access to parts of the chaincode, are used to encrypt the keys associated to their access rights:

        SKc for the users to be able to read any message associated to that chain-code (invocation, state, etc),

        KC for the user to be able to read only the contract code,

        KH for the user to only be able to read the headers,

        KS for the user to be able to read the state associated to that contract.

    Finally users are given the contract's public key PKc, for them to be able to encrypt information related to that contract for the validators (or any in possession of SKc) to be able to read it. Transaction certificate of each contract user is appended to the transaction and follows that user's message. This is done for users to be able to easily search the blockchain for transactions they have been part of. Notice that the deployment transaction also appends a message to the creator uc of the chain-code, for the latter to be able to retrieve this transaction through parsing the ledger and without keeping any state locally.

The entire transaction is signed by a certificate of the chaincode creator, i.e., enrollment or transaction certificate as decided by the latter. Two noteworthy points:

    Messages that are included in a transaction in an encrypted format, i.e., code-functions, code-hdrs, are signed before they are encrypted using the same TCert the entire transaction is signed with, or even with a different TCert or the ECert of the user (if the transaction deployment should carry the identity of its owner. A binding to the underlying transaction carrier should be included in the signed message, e.g., the hash of the TCert the transaction is signed, such that mix&match attacks are not possible. Though we detail such attacks in Section 4.4, in these cases an attacker who sees a transaction should not be able to isolate the ciphertext corresponding to, e.g., code-info, and use it for another transaction of her own. Clearly, such an ability would disrupt the operation of the system, as a chaincode that was first created by user A, will now also belong to malicious user B (who is not even able to read it).
    To offer the ability to the users to cross-verify they are given access to the correct key, i.e., to the same key as the other contract users, transaction ciphertexts that are encrypted with a key K are accompanied by a commitment to K, while the opening of this commitment value is passed to all users who are entitled access to K in contract-users, and chain-validator sections. <!-- @adecaro: please REVIEW this! --> In this way, anyone who is entitled access to that key can verify that the key has been properly passed to it. This part is omitted in the figure above to avoid confusion.

Structure of invoke transaction. A transaction invoking the chain-code triggering the execution of a function of the chain-code with user-specified arguments is structured as depicted in the figure below.

FirstRelease-deploy

Invocation transaction as in the case of deployment transaction consists of a general-info section, a code-info section, a section for the chain-validators, and one for the contract users, signed altogether with one of the invoker's transaction certificates.

    General-info follows the same structure as the corresponding section of the deployment transaction. The only difference relates to the transaction type that is now set to ''InvocTx'', and the chain-code identifier or name that is now encrypted under the chain-specific encryption (public) key.

    Code-info exhibits the same structure as the one of the deployment transaction. Code payload, as in the case of deployment transaction, consists of function invocation details (the name of the function invoked, and associated arguments), code-metadata provided by the application and the transaction's creator (invoker's u) certificate, TCertu. Code payload is signed by the transaction certificate TCertu of the invoker u, as in the case of deploy transactions. As in the case of deploy transactions, code-metadata, and tx-metadata, are fields that are provided by the application and can be used (as described in Section 4.4), for the latter to implement their own access control mechanisms and roles.

    Finally, contract-users and chain-validator sections provide the key the payload is encrypted with, the invoker's key, and the chain encryption key respectively. Upon receiving such transactions, the validators decrypt [code-name]PKchain using the chain-specific secret key SKchain and obtain the invoked chain-code identifier. Given the latter, validators retrieve from their local storage the chaincode's decryption key SKc, and use it to decrypt chain-validators' message, that would equip them with the symmetric key KI the invocation transaction's payload was encrypted with. Given the latter, validators decrypt code-info, and execute the chain-code function with the specified arguments, and the code-metadata attached(See, Section 4.4 for more details on the use of code-metadata). While the chain-code is executed, updates of the state of that chain-code are possible. These are encrypted using the state-specific key Ks that was defined during that chain-code's deployment. In particular, Ks is used the same way KiTx is used in the design of our current release (See, Section 4.7).

Structure of query transaction. Query transactions have the same format as invoke transactions. The only difference is that Query transactions do not affect the state of the chaincode, and thus there is no need for the state to be retrieved (decrypted) and/or updated (encrypted) after the execution of the chaincode completes.

### 4.3.2.2 Confidentiality against validators

This section deals with ways of how to support execution of certain transactions under a different (or subset) sets of validators in the current chain. This section inhibits IP restrictions and will be expanded in the following few weeks.

### 4.3.3 预防重复播放攻击（Replay attack resistance）

在重播攻击中，攻击者"重播"它在网络上"偷听"或 区块链上'看见'的一条消息。重播攻击是一个很大的问题，他们可以致使验证实体重新进行计算密集型的过程 （链码调用）和/或影响相应链码的状态，而攻击者只有很小甚至没有任何代价。如果是一个付款交易的话事情更糟，回放可能导致成付款进行不止一次，明显违背付款人的初衷。现有系统抵抗重放攻击，如下所示︰
    
+ 记录系统中交易的哈希值。此方案需要验证者维护日志记录网络中公布的每笔交易的哈希值，并且将新交易与本地存储的交易记录进行比对。显然这种方法对于大型网络伸缩性有很大影响，且很容易导致到验证者花费大量的时间来检查交易是否被重播，比执行实际的交易花费的时间多得多。

+ 利用每个用户保持的状态（Ethereum）。Ethereum维护某种状态，例如，为系统中每个身份/化名设置计数器（初值为 1）。用户也维护自己的计数器 （初值为 0）。每次用户发送使用自己身份/化名的交易，就在用户本地的计数器加一，并将所得到的结果值添加到交易中。交易随后以该用户身份签发到网络。当收到这笔交易，验证者检查交易记录的计数器值并与自己本地维护的进行比较；如果值是相同的则增加本地该用户的计数器值，并且接受交易。否则，交易会被认为是无效或重播的而被拒绝。虽然这个方案在用户数量不太大的情况下效果较好，在用户每个交易使用不同的身份标识（交易证书）并因此用户化名数与交易数目成一定比例的情况下，最终系统仍会失去伸缩性。

其他资产管理系统，例如，比特币，虽然不是直接处理重放攻击，但也在预防这种攻击。在管理 （数字） 资产的系统中，状态在每个资产基础记录上进行维护，即验证者只记录下谁拥有什么。这可以直接防止重放攻击，根据协议（因为只会？？？显示？？？从资产/硬币的拥有者派生的）重放的交易将立即被视为无效。虽然这适用于资产管理系统，但并不适用于比资产管理系统更为通用的区块链系统的需求。

在fabric 中，抵御重放攻击使用一种混合方法。用户在交易中添加一个随机数，这个随机数根据交易匿名 （遵循并由交易证书签名）或不匿名 （遵循并由长期有效地注册证书签名）由不同的矿工生成。具体如下：
    
+ 用户提交其注册证书签发的交易应包括一个nonce（任意非重复值），由先前相同证书签发的交易中使用的nonce函数（例如，计数器函数或哈希）产生。每个注册证书的第一个交易也可以由系统预设（例如，包含在初始区块上） 或由用户选择。在第一种情况下，初始区块随机数计算需要引入参数 nonceall，即用户使用一个常数和用户身份IDA携带的随机数来签署其注册证书的第一个交易

    注册证书中会存在IDA，nonceround{0}IDA <- hash(IDA, nonceall)。从该点起后续由该用户注册证书签发的交易都将包括如下的nonce： nonceround{i}IDA <- hash(nonceround{i-1}IDA)，即第 i个交易随机数会使用同一证书第{i-1}个交易的nonce的哈希值。验证者在这里继续处理他们接收到的交易，只要它满足上述条件。成功验证交易格式后，验证者将该nonce保存到他们的数据库中。

    存储开销：

        在用户端：最近使用的nonce,

        在验证者端：O(n), n为用户数。

+ 用户提交交易证书签发的交易应包括一个随机任意唯一值（随机nonce/random nonce），这将保证两个事务不会得到相同的哈希值。如果签发交易的交易证书未过期，验证者会将交易的哈希值保存在本地数据库中。为避免存储大量的哈希值，可通过交易证书有效期来调节。特别是验证者维护一个更新记录，记录当前或未来的有效期内收到的交易哈希值。

    存储开销：

        只有验证者端：O(m)，m值接近于有效期中的交易数和对应有效期内的身份标识数（见后）。

### 4.4 Access control features on the application

An application, is a piece of software that runs on top of a Blockchain client software, and, performs a special task over the Blockchain, i.e., restaurant table reservation. Application software have a version of developer, enabling the latter to generate and manage a couple of chaincodes that are necessary for the business this application serves, and a client-version that would allow the application's end-users to make use of the application, by invoking these chain-codes. The use of the Blockchain can be transparent to the application end-users or not.

This section describes how an application leveraging chaincodes can implement its own access control policies, and guidelines on how our Membership services PKI can be leveraged for the same purpose.

The presentation is divided into enforcement of invocation access control, and enforcement of read-access control by the application.

### 4.4.1 Invocation access control

To allow the application to implement its own invocation access control at the application layer securely, special support by the fabric must be provided. In the following we elaborate on the tools exposed by the fabric to the application for this purpose, and provide guidelines on how these should be used by the application for the latter to enforce access control securely.

Support from the infrastructure. For the chaincode creator, let it be, uc, to be able to implement its own invocation access control at the application layer securely, special support by the fabric must be provided. More specifically fabric layer gives access to following capabilities:

    The client-application can request the fabric to sign and verify any message with specific transaction certificates or enrollment certificate the client owns; this is expressed via the Certificate Handler interface

    The client-application can request the fabric a unique binding to be used to bind authentication data of the application to the underlying transaction transporting it; this is expressed via the Transaction Handler interface

    Support for a transaction format, that allows for the application to specify metadata, that are passed to the chain-code at deployment, and invocation time; the latter denoted by code-metadata.

The Certificate Handler interface allows to sign and verify any message using signing key-pair underlying the associated certificate. The certificate can be a TCert or an ECert.

// CertificateHandler exposes methods to deal with an ECert/TCert
type CertificateHandler interface {

    // GetCertificate returns the certificate's DER
    GetCertificate() []byte

    // Sign signs msg using the signing key corresponding to the certificate
    Sign(msg []byte) ([]byte, error)

    // Verify verifies msg using the verifying key corresponding to the certificate
    Verify(signature []byte, msg []byte) error

    // GetTransactionHandler returns a new transaction handler relative to this certificate
    GetTransactionHandler() (TransactionHandler, error)
}

The Transaction Handler interface allows to create transactions and give access to the underlying binding that can be leveraged to link application data to the underlying transaction. Bindings are a concept that have been introduced in network transport protocols (See, https://tools.ietf.org/html/rfc5056), known as channel bindings, that allows applications to establish that the two end-points of a secure channel at one network layer are the same as at a higher layer by binding authentication at the higher layer to the channel at the lower layer. This allows applications to delegate session protection to lower layers, which has various performance benefits. Transaction bindings offer the ability to uniquely identify the fabric layer of the transaction that serves as the container that application data uses to be added to the ledger.

// TransactionHandler represents a single transaction that can be uniquely determined or identified by the output of the GetBinding method.
// This transaction is linked to a single Certificate (TCert or ECert).
type TransactionHandler interface {

    // GetCertificateHandler returns the certificate handler relative to the certificate mapped to this transaction
    GetCertificateHandler() (CertificateHandler, error)

    // GetBinding returns a binding to the underlying transaction (container)
    GetBinding() ([]byte, error)

    // NewChaincodeDeployTransaction is used to deploy chaincode
    NewChaincodeDeployTransaction(chaincodeDeploymentSpec *obc.ChaincodeDeploymentSpec, uuid string) (*obc.Transaction, error)

    // NewChaincodeExecute is used to execute chaincode's functions
    NewChaincodeExecute(chaincodeInvocation *obc.ChaincodeInvocationSpec, uuid string) (*obc.Transaction, error)

    // NewChaincodeQuery is used to query chaincode's functions
    NewChaincodeQuery(chaincodeInvocation *obc.ChaincodeInvocationSpec, uuid string) (*obc.Transaction, error)
}

For version 1, binding consists of the hash(TCert, Nonce), where TCert, is the transaction certificate used to sign the entire transaction, while Nonce, is the nonce number used within.

The Client interface is more generic, and offers a mean to get instances of the previous interfaces.

type Client interface {

    ...

    // GetEnrollmentCertHandler returns a CertificateHandler whose certificate is the enrollment certificate
    GetEnrollmentCertificateHandler() (CertificateHandler, error)

    // GetTCertHandlerNext returns a CertificateHandler whose certificate is the next available TCert
    GetTCertificateHandlerNext() (CertificateHandler, error)

    // GetTCertHandlerFromDER returns a CertificateHandler whose certificate is the one passed
    GetTCertificateHandlerFromDER(der []byte) (CertificateHandler, error)

}

To support application-level access control lists for controlling chaincode invocation, the fabric's transaction and chaincode specification format have an additional field to store application-specific metadata. This field is depicted in both figures 1, by code-metadata. The content of this field is decided by the application, at the transaction creation time. The fabric layer treats it as an unstructured stream of bytes.


message ChaincodeSpec {

    ...

    ConfidentialityLevel confidentialityLevel;
    bytes metadata;

    ...
}


message Transaction {
    ...

    bytes payload;
    bytes metadata;

    ...
}

To assist chaincode execution, at the chain-code invocation time, the validators provide the chaincode with additional information, like the metadata and the binding.

Application invocation access control. This section describes how the application can leverage the means provided by the fabric to implement its own access control on its chain-code functions. In the scenario considered here, the following entities are identified:

    C: is a chaincode that contains a single function, e.g., called hello;

    uc: is the C deployer;

    ui: is a user who is authorized to invoke C's functions. User uc wants to ensure that only ui can invoke the function hello.

Deployment of a Chaincode: At deployment time, uc has full control on the deployment transaction's metadata, and can be used to store a list of ACLs (one per function), or a list of roles that are needed by the application. The format which is used to store these ACLs is up to the deployer's application, as the chain-code is the one who would need to parse the metadata at execution time. To define each of these lists/roles, uc can use any TCerts/Certs of the ui (or, if applicable, or other users who have been assigned that privilege or role). Let this be TCertui. The exchange of TCerts or Certs among the developer and authorized users is done through an out-of-band channel.

Assume that the application of uc's requires that to invoke the hello function, a certain message M has to be authenticated by an authorized invoker (ui, in our example). One can distinguish the following two cases:

    M is one of the chaincode's function arguments;

    M is the invocation message itself, i.e., function-name, function-arguments.

Chaincode invocation: To invoke C, ui's application needs to sign M using the TCert/ECert, that was used to identify ui's participation in the chain-code at the associated deployment transaction's metadata, i.e., TCertui. More specifically, ui's client application does the following:

    Retrieves a CertificateHandler for Certui, cHandler;

    obtains a new TransactionHandler to issue the execute transaction, txHandler relative to his next available TCert or his ECert;

    gets txHandler's binding by invoking txHandler.getBinding();

    signs 'M* || txBinding'* by invoking cHandler.Sign('M* || txBinding'), let *sigma be the output of the signing function;

    issues a new execute transaction by invoking, txHandler.NewChaincodeExecute(...). Now, sigma can be included in the transaction as one of the arguments that are passed to the function (case 1) or as part of the code-metadata section of the payload(case 2).

Chaincode processing: The validators, who receive the execute transaction issued ui, will provide to hello the following information:

    The binding of the execute transaction, that can be independently computed at the validator side;

    The metadata of the execute transaction (code-metadata section of the transaction);

    The metadata of the deploy transaction (code-metadata component of the corresponding deployment transaction).

Notice that sigma is either part of the arguments of the invoked function, or stored inside the code-metadata of the invocation transaction (properly formatted by the client-application). Application ACLs are included in the code-metadata section, that is also passed to the chain-code at execution time. Function hello is responsible for checking that sigma is indeed a valid signature issued by TCertui, on 'M || txBinding'.

### 4.4.2 Read access control

This section describes how the fabric's infrastructure offers support to the application to enforce its own read-access control policies at the level of users. As in the case of invocation access control, the first part describes the infrastructure features that can be leveraged by the application for this purpose, and the last part details on the way applications should use these tools.

For the purpose of this discussion, we leverage a similar example as before, i.e.,

    C: is a chaincode that contains a single function, e.g., called hello;

    uA: is the C's deployer, also known as application;

    ur: is a user who is authorized to read C's functions. User uA wants to ensure that only ur can read the function hello.

Support from the infrastructure. For uA to be able to implement its own read access control at the application layer securely, our infrastructure is required to support the transaction format for code deployment and invocation, as depicted in the two figures below.

SecRelease-RACappDepl title="Deployment transaction format supporting application-level read access control."

SecRelease-RACappInv title="Invocation transaction format supporting application-level read access control."

More specifically fabric layer is required to provide the following functionality:

    Provide minimal encryption capability such that data is only decryptable by a validator's (infrastructure) side; this means that the infrastructure should move closer to our future version, where an asymmetric encryption scheme is used for encrypting transactions. More specifically, an asymmetric key-pair is used for the chain, denoted by Kchain in the Figures above, but detailed in Section Transaction Confidentiality.

    The client-application can request the infrastructure sitting on the client-side to encrypt/decrypt information using a specific public encryption key, or that client's long-term decryption key.

    The transaction format offers the ability to the application to store additional transaction metadata, that can be passed to the client-application after the latter's request. Transaction metadata, as opposed to code-metadata, is not encrypted or provided to the chain-code at execution time. Validators treat these metadata as a list of bytes they are not responsible for checking validity of.

Application read-access control. For this reason the application may request and obtain access to the public encryption key of the user ur; let that be PKur. Optionally, ur may be providing uA with a certificate of its, that would be leveraged by the application, say, TCertur; given the latter, the application would, e.g., be able to trace that user's transactions w.r.t. the application's chain-codes. TCertur, and PKur, are exchanged in an out-of-band channel.

At deployment time, application uA performs the following steps:

    Uses the underlying infrastructure to encrypt the information of C, the application would like to make accessible to ur, using PKur. Let Cur be the resulting ciphertext.

    (optional) Cur can be concatenated with TCertur

    Passes the overall string as ''Tx-metadata'' of the confidential transaction to be constructed.

At invocation time, the client-application on ur's node, would be able, by obtaining the deployment transaction to retrieve the content of C. It just needs to retrieve the tx-metadata field of the associated deployment transaction, and trigger the decryption functionality offered by our Blockchain infrastrucure's client, for Cur. Notice that it is the application's responsibility to encrypt the correct C for ur. Also, the use of tx-metadata field can be generalized to accommodate application-needs. E.g., it can be that invokers leverage the same field of invocation transactions to pass information to the developer of the application, etc.

Important Note: It is essential to note that validators do not provide any decryption oracle to the chain-code throughout its execution. Its infrastructure is though responsible for decrypting the payload of the chain-code itself (as well as the code-metadata fields near it), and provide those to containers for deployment/execution.

### 4.5 在线钱包服务（Online wallet service）

本节介绍钱包服务的安全设计，单节点，终端用户可以注册，储存关键材料，可以执行交易。因为钱包服务拥有用户的关键材料，很明显，如果没有安全授权机制恶意钱包服务可以成功地模拟用户。因此我们强调，这种设计针对只代表客户端执行交易的授信钱包服务。终端用户登记到在线钱包服务有两种情况：

    1. 当用户已在登记机构登记并获得< enrollID，enrollPWD >，但还没有安装客户端触发并完成注册过程；

    2. 当用户已经安装了客户端，并完成注册阶段。

最初，用户与在线钱包服务交互从而发布凭证，以使用户自身能够获得钱包服务身份认证。这样用户获得用户名和密码，用户名是用户在成员服务中的身份标识，由 AccPub表示，密码是加密的，由 AccSec表示，被用户和服务共享。

通过在线钱包服务注册，用户必须向钱包服务提供如下请求对象：
```
AccountRequest /* account request of u \*/
{
    OBCSecCtx ,           /* credentials associated to network \*/
    AccPub<sub>u</sub>,   /* account identifier of u \*/
    AccSecProof<sub>u</sub>  /* proof of AccSec<sub>u</sub>\*/
}
```

OBCSecCtx 指向用户凭据，这依赖于用户具体的注册过程，可能是用户注册 ID和密码，< enrollID，enrollPWD >或用户的注册证书以及相关密钥（多个）(ECertu，sku)，其中 sku 表示为简单签名和解密密钥。？？？AccSecProofu 内容HMAC 使用的共享密钥请求的其余字段。？？？基于nonce 的方法类似于我们在fabric 中用于防止重方攻击的方案。OBCSecCtx 会提供给在线钱包服务必要的信息以便注册用户或发布所需的交易证书（TCerts）。

接着，用户会向钱包服务提供类似如下格式的请求。
```
TransactionRequest /* account request of u \*/
{
    TxDetails,            /* specifications for the new transaction \*/
    AccPub<sub>u</sub>,       /* account identifier of u \*/
    AccSecProof<sub>u</sub>   /* proof of AccSec<sub>u</sub> \*/
}
```

如上所示，TxDetails 指向在线服务代表用户构建交易时所需的信息，即，类型和交易中特定用户的内容。

？？？AccSecProofu 仍然HMAC 使用的共享密钥请求的其余字段。？？？基于nonce 的方法类似于我们在fabric 中用于防止重方攻击的方案。

TLS 连接可用于网络层在与服务器授权访问时保证请求的安全 （保密、 重放攻击防护，等等）。

### 4.6 网络安全（TLS）

TLS CA 应能够给非验证点，验证者颁发TLS 证书，和独立客户端 （或能够存储私钥的浏览器）。最好，这些证书通过类型区分。TLS 证书可以提供给多种不同类型的CA（如 TLS CA、 ECA、 TCA） ，可以由中间 CA (即，是属于根 CA 的 CA)发布。如果不是一个特别的网络分析任务，除了申请TLS 证书的TLS CA 请求，任何给定的 TLS 连接可以进行相互身份验证。

在当前实现中唯一信任基础是TLS CA 自签名的证书，以容纳单个端口与所有三个（合用）服务器通信，即，TLS CA、 TCA 和ECA。因此，TLS 需要与TLS CA建立握手，TLS CA 会将由此产生的会话密钥传送给TCA 和ECA。TCA 和ECA 自签名证书的有效性继承自TLS CA 的信任。这种实现不会因此使TLS CA 凌驾于其他CA，信任基础应被根CA 替换，而根CA 应当认证了TLS CA 和所有其他 CA。

### 4.7 Restrictions in the current release

This section lists the restrictions of the current release of the fabric. A particular focus is given on client operations and the design of transaction confidentiality, as depicted in Sections 4.7.1 and 4.7.2.

    Client side enrollment and transaction creation is performed entirely by a non-validating peer that is trusted not to impersonate the user. See, Section 4.7.1 for more information.
    A minimal set of confidentiality properties where a chaincode is accessible by any entity that is member of the system, i.e., validators and users who have registered through Hyperledger Fabric's Membership Services and is not accessible by anyone else. The latter include any party that has access to the storage area where the ledger is maintained, or other entities that are able to see the transactions that are announced in the validator network. The design of the first release is detailed in subsection 4.7.2
    The code utilizes self-signed certificates for entities such as the enrollment CA (ECA) and the transaction CA (TCA)
    Replay attack resistance mechanism is not available
    Invocation access control can be enforced at the application layer: it is up to the application to leverage the infrastructure's tools properly for security to be guaranteed. This means, that if the application fails to bind the transaction binding offered by the fabric, secure transaction processing may be at risk.

### 4.7.1 Simplified client

Client-side enrollment and transaction creation are performed entirely by a non-validating peer that plays the role of an online wallet. In particular, the end-user leverages their registration credentials to open an account to a non-validating peer and uses these credentials to further authorize the peer to build transactions on the user's behalf. It needs to be noted, that such a design does not provide secure authorization for the peer to submit transactions on behalf of the user, as a malicious peer could impersonate the user. Details on the specifications of a design that deals with the security issues of online wallet can be found is Section 4.5. Currently the maximum number of peers a user can register to and perform transactions through is one.

#### 4.7.2 Simplified transaction confidentiality

Disclaimer: The current version of transaction confidentiality is minimal, and will be used as an intermediate step to reach a design that allows for fine grained (invocation) access control enforcement in a subsequent release.

In its current form, confidentiality of transactions is offered solely at the chain-level, i.e., that the content of a transaction included in a ledger, is readable by all members of that chain, i.e., validators and users. At the same time, application auditors who are not members of the system can be given the means to perform auditing by passively observing the blockchain data, while guaranteeing that they are given access solely to the transactions related to the application under audit. State is encrypted in a way that such auditing requirements are satisfied, while not disrupting the proper operation of the underlying consensus network.

More specifically, currently symmetric key encryption is supported in the process of offering transaction confidentiality. In this setting, one of the main challenges that is specific to the blockchain setting, is that validators need to run consensus over the state of the blockchain, that, aside from the transactions themselves, also includes the state updates of individual contracts or chaincode. Though this is trivial to do for non-confidential chaincode, for confidential chaincode, one needs to design the state encryption mechanism such that the resulting ciphertexts are semantically secure, and yet, identical if the plaintext state is the same.

To overcome this challenge, the fabric utilizes a key hierarchy that reduces the number of ciphertexts that are encrypted under the same key. At the same time, as some of these keys are used for the generation of IVs, this allows the validating parties to generate exactly the same ciphertext when executing the same transaction (this is necessary to remain agnostic to the underlying consensus algorithm) and offers the possibility of controlling audit by disclosing to auditing entities only the most relevant keys.

Method description: Membership service generates a symmetric key for the ledger (Kchain) that is distributed at registration time to all the entities of the blockchain system, i.e., the clients and the validating entities that have issued credentials through the membership service of the chain. At enrollment phase, user obtain (as before) an enrollment certificate, denoted by Certui for user ui , while each validator vj obtains its enrollment certificate denoted by Certvj.

Entity enrollment would be enhanced, as follows. In addition to enrollment certificates, users who wish to anonymously participate in transactions issue transaction certificates. For simplicity transaction certificates of a user ui are denoted by TCertui. Transaction certificates include the public part of a signature key-pair denoted by (tpkui,tskui).

In order to defeat crypto-analysis and enforce confidentiality, the following key hierarchy is considered for generation and validation of confidential transactions: To submit a confidential transaction (Tx) to the ledger, a client first samples a nonce (N), which is required to be unique among all the transactions submitted to the blockchain, and derive a transaction symmetric key (KTx) by applying the HMAC function keyed with Kchain and on input the nonce, KTx= HMAC(Kchain, N). From KTx, the client derives two AES keys: KTxCID as HMAC(KTx, c1), KTxP as HMAC(KTx, c2)) to encrypt respectively the chain-code name or identifier CID and code (or payload) P. c1, c2 are public constants. The nonce, the Encrypted Chaincode ID (ECID) and the Encrypted Payload (EP) are added in the transaction Tx structure, that is finally signed and so authenticated. Figure below shows how encryption keys for the client's transaction are generated. Arrows in this figure denote application of an HMAC, keyed by the key at the source of the arrow and using the number in the arrow as argument. Deployment/Invocation transactions' keys are indicated by d/i respectively.

FirstRelease-clientSide

To validate a confidential transaction Tx submitted to the blockchain by a client, a validating entity first decrypts ECID and EP by re-deriving KTxCID and KTxP from Kchain and Tx.Nonce as done before. Once the Chaincode ID and the Payload are recovered the transaction can be processed.

FirstRelease-validatorSide

When V validates a confidential transaction, the corresponding chaincode can access and modify the chaincode's state. V keeps the chaincode's state encrypted. In order to do so, V generates symmetric keys as depicted in the figure above. Let iTx be a confidential transaction invoking a function deployed at an early stage by the confidential transaction dTx (notice that iTx can be dTx itself in the case, for example, that dTx has a setup function that initializes the chaincode's state). Then, V generates two symmetric keys KIV and Kstate as follows:

    It computes as KdTx , i.e., the transaction key of the corresponding deployment transaction, and then Nstate = HMAC(Kdtx ,hash(Ni)), where Ni is the nonce appearing in the invocation transaction, and hash a hash function.
    It sets Kstate = HMAC(KdTx, c3 || Nstate), truncated opportunely deeding on the underlying cipher used to encrypt; c3 is a constant number
    It sets KIV = HMAC(KdTx, c4 || Nstate); c4 is a constant number

In order to encrypt a state variable S, a validator first generates the IV as HMAC(KIV, crtstate) properly truncated, where crtstate is a counter value that increases each time a state update is requested for the same chaincode invocation. The counter is discarded after the execution of the chaincode terminates. After IV has been generated, V encrypts with authentication (i.e., GSM mode) the value of S concatenated with Nstate(Actually, Nstate doesn't need to be encrypted but only authenticated). To the resulting ciphertext (CT), Nstate and the IV used is appended. In order to decrypt an encrypted state CT|| Nstate' , a validator first generates the symmetric keys KdTX' ,Kstate' using Nstate' and then decrypts CT.

Generation of IVs: In order to be agnostic to any underlying consensus algorithm, all the validating parties need a method to produce the same exact ciphertexts. In order to do so, the validators need to use the same IVs. Reusing the same IV with the same symmetric key completely breaks the security of the underlying cipher. Therefore, the process described before is followed. In particular, V first derives an IV generation key KIV by computing HMAC(KdTX, c4 || Nstate ), where c4 is a constant number, and keeps a counter crtstate for the pair (dTx, iTx) with is initially set to 0. Then, each time a new ciphertext has to be generated, the validator generates a new IV by computing it as the output of HMAC(KIV, crtstate) and then increments the crtstate by one.

Another benefit that comes with the above key hierarchy is the ability to enable controlled auditing. For example, while by releasing Kchain one would provide read access to the whole chain, by releasing only Kstate for a given pair of transactions (dTx,iTx) access would be granted to a state updated by iTx, and so on.

The following figures demonstrate the format of a deployment and invocation transaction currently available in the code.

FirstRelease-deploy

FirstRelease-deploy

One can notice that both deployment and invocation transactions consist of two sections:

    Section general-info: contains the administration details of the transaction, i.e., which chain this transaction corresponds to (is chained to), the type of transaction (that is set to ''deploymTx'' or ''invocTx''), the version number of confidentiality policy implemented, its creator identifier (expressed by means of TCert of Cert) and a nonce (facilitates primarily replay-attack resistance techniques).

    Section code-info: contains information on the chain-code source code. For deployment transaction this is essentially the chain-code identifier/name and source code, while for invocation chain-code is the name of the function invoked and its arguments. As shown in the two figures code-info in both transactions are encrypted ultimately using the chain-specific symmetric key Kchain.

### 5. 拜占庭共识协议

https://github.com/hyperledger/fabric/tree/master/consensus/pbft

pbft 包是共识协议PBFT 的一种开创性实现[1]，其在验证点间提供的共识协议能够允许阈值限制数目内的验证点成为拜占庭，即被恶意的或不可预知的方式失败。在默认配置中，PBFT 可以容忍t < n/3 拜占庭验证点。

在默认配置中，PBFT 设计为在运行至少3t + 1 个验证器（副本），容忍到t 个副本可能出现故障（包括恶意，或拜占庭式）。

### 5.1 概览

pbft 插件是共识协议PBFT 的一种实现。

### 5.2 PBFT 核心方法

以下方法控制并行使用非递归锁，因此可以从多个线程的并行调用。尽管这些方法通常能够完成运行，而且可能会调用通过CPI 传入的方法，但仍须注意防止造成活锁。

### 5.2.1 newPbftCore 方法

方法签名
```
func newPbftCore(id uint64, config *viper.Viper, consumer innerCPI, ledger consensus.Ledger) *pbftCore
```

newPbftCore 构造函数使用指定的id 实例化一个新的PBFT 封装实例。配置参数定义了PBFT 网络运行参数： 副本数N、 检查点周期K、以及请求超时和视图更改超时。

### 10. 参考

+ [1] Miguel Castro, Barbara Liskov: Practical Byzantine fault tolerance and proactive recovery. ACM Trans. Comput. Syst. 20(4): 398-461 (2002)

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

+ event - 事件

+ issue transaction 和submit transaction 的区别？

+ the stack 是指堆栈么？

+ consensus - 共识协议

+ noops 插件是什么？

+ Multichain - 多链

+ message - 消息

+ Message proto structure - 消息原型结构

+ Accountability - 可追溯

+ non-frameability - 不可伪造

+ ECerts - 注册证书

+ TCerts - 交易证书

+ CA - 证书颁发机构

+ out-of-band communication - 带外通信

+ registration credential - 登记凭证

+ Enrollment Certificate Authority

+ Transaction Certificate Authority

+ TLS Certificate Authority

+ signature key-pair

+ encryption/key agreement key-pair

+ Replay attack - 重复播放攻击/重放攻击
 
+ Ethereum

+ nonce

+ trust anchor - 信任基础

+ livelock - 活锁  
    活锁指的是任务或者执行者没有被阻塞，由于某些条件没有满足，导致一直重复尝试，失败，尝试，失败。
