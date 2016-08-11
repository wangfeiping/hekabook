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

成员（Membership）服务提供网络身份标识、私密性（Privacy）、保密性（Confidentiality）以及可审计性（Auditability）的管理。在非权限的区块链网络中，参与不需要授权并且所有节点能够平等的提交交易或尝试积累这些（交易？）为可接受的数据块，即参与角色没有区别。成员（Membership）服务结合PKI（Public Key Infrastructure）以及下发（decentralization）和一致性协商（consensus）等元素，将非权限区块链网络转换为权限区块链网络。在后者中，实体通过注册获得长期的身份凭证 （注册证书），并且可以根据实体类型进行区分。对于用户来说，这些证书具有TCA（Transaction Certificate Authority/交易凭证权限）可以发布匿名凭证这些凭证，即交易凭证，被用于授权提交交易。交易凭证保存在区块链网络中，能够使已授权的审计者访问集群中其他非关联的交易。

### 2.1.2 区块链（Blockchain）服务

区块链（Blockchain）服务通过点对点协议管理分布式账本，基于HTTP/2。数据结构经过高度的优化并提供了高效的哈希算法用于维护世界状态（World State）的复制。不同的一致性协商协议（PBFT, Raft, PoW, PoS）可以在每一次部署中配置选择和接入。

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

单点验证点（Validating peer）不需要一致性协商协议，并且默认使用？（noops）插件，该插件可以在接收到交易后即可运行交易。这使开发者可以在开发阶段立即得到运行结果反馈。

### 2.2.2 多验证点（Validating Peer）

生产或测试网络应该由多个验证点（Validating Peer）和非验证点（Non-validating peer）组成。非验证点（Non-validating peer）能够分担验证点（Validating Peer）的压力，例如处理API 请求和事件。

多验证点（Validating Peer）/图

验证点（Validating Peer）通过组成的网状网络（每个验证点都与其他验证点相连）来传输信息。非验证点（Non-validating peer）链接相邻的允许其链接的验证点（Validating Peer）。非验证点（Non-validating peer）是可选的因为应用可以直接访问验证点（Validating Peer）。

### 2.2.3 多链（Multichain）

每个由验证点和非验证点组成的网络形成一条链。多条链可以针对不同的需求，类似于多个网站，每个网站都可以服务于一个不同的目的。

3. Protocol

The fabric's peer-to-peer communication is built on gRPC, which allows bi-directional stream-based messaging. It uses Protocol Buffers to serialize data structures for data transfer between peers. Protocol buffers are a language-neutral, platform-neutral and extensible mechanism for serializing structured data. Data structures, messages, and services are described using proto3 language notation.
3.1 Message

Messages passed between nodes are encapsulated by Message proto structure, which consists of 4 types: Discovery, Transaction, Synchronization, and Consensus. Each type may define more subtypes embedded in the payload.

message Message {
   enum Type {
        UNDEFINED = 0;

        DISC_HELLO = 1;
        DISC_DISCONNECT = 2;
        DISC_GET_PEERS = 3;
        DISC_PEERS = 4;
        DISC_NEWMSG = 5;

        CHAIN_STATUS = 6;
        CHAIN_TRANSACTION = 7;
        CHAIN_GET_TRANSACTIONS = 8;
        CHAIN_QUERY = 9;

        SYNC_GET_BLOCKS = 11;
        SYNC_BLOCKS = 12;
        SYNC_BLOCK_ADDED = 13;

        SYNC_STATE_GET_SNAPSHOT = 14;
        SYNC_STATE_SNAPSHOT = 15;
        SYNC_STATE_GET_DELTAS = 16;
        SYNC_STATE_DELTAS = 17;

        RESPONSE = 20;
        CONSENSUS = 21;
    }
    Type type = 1;
    bytes payload = 2;
    google.protobuf.Timestamp timestamp = 3;
}

The payload is an opaque byte array containing other objects such as Transaction or Response depending on the type of the message. For example, if the type is CHAIN_TRANSACTION, the payload is a Transaction object.
3.1.1 Discovery Messages

Upon start up, a peer runs discovery protocol if CORE_PEER_DISCOVERY_ROOTNODE is specified. CORE_PEER_DISCOVERY_ROOTNODE is the IP address of another peer on the network (any peer) that serves as the starting point for discovering all the peers on the network. The protocol sequence begins with DISC_HELLO, whose payload is a HelloMessage object, containing its endpoint:

message HelloMessage {
  PeerEndpoint peerEndpoint = 1;
  uint64 blockNumber = 2;
}
message PeerEndpoint {
    PeerID ID = 1;
    string address = 2;
    enum Type {
      UNDEFINED = 0;
      VALIDATOR = 1;
      NON_VALIDATOR = 2;
    }
    Type type = 3;
    bytes pkiID = 4;
}

message PeerID {
    string name = 1;
}

Definition of fields:

    PeerID is any name given to the peer at start up or defined in the config file
    PeerEndpoint describes the endpoint and whether it's a validating or a non-validating peer
    pkiID is the cryptographic ID of the peer
    address is host or IP address and port of the peer in the format ip:port
    blockNumber is the height of the blockchain the peer currently has

If the block height received upon DISC_HELLO is higher than the current block height of the peer, it immediately initiates the synchronization protocol to catch up with the network.

After DISC_HELLO, peer sends DISC_GET_PEERS periodically to discover any additional peers joining the network. In response to DISC_GET_PEERS, a peer sends DISC_PEERS with payload containing an array of PeerEndpoint. Other discovery message types are not used at this point.
3.1.2 Transaction Messages

There are 3 types of transactions: Deploy, Invoke and Query. A deploy transaction installs the specified chaincode on the chain, while invoke and query transactions call a function of a deployed chaincode. Another type in consideration is Create transaction, where a deployed chaincode may be instantiated on the chain and is addressable. This type has not been implemented as of this writing.
3.1.2.1 Transaction Data Structure

Messages with type CHAIN_TRANSACTION or CHAIN_QUERY carry a Transaction object in the payload:

message Transaction {
    enum Type {
        UNDEFINED = 0;
        CHAINCODE_DEPLOY = 1;
        CHAINCODE_INVOKE = 2;
        CHAINCODE_QUERY = 3;
        CHAINCODE_TERMINATE = 4;
    }
    Type type = 1;
    string uuid = 5;
    bytes chaincodeID = 2;
    bytes payloadHash = 3;

    ConfidentialityLevel confidentialityLevel = 7;
    bytes nonce = 8;
    bytes cert = 9;
    bytes signature = 10;

    bytes metadata = 4;
    google.protobuf.Timestamp timestamp = 6;
}

message TransactionPayload {
    bytes payload = 1;
}

enum ConfidentialityLevel {
    PUBLIC = 0;
    CONFIDENTIAL = 1;
}

Definition of fields:

    type - The type of the transaction, which is 1 of the following:
        UNDEFINED - Reserved for future use.
        CHAINCODE_DEPLOY - Represents the deployment of a new chaincode.
            CHAINCODE_INVOKE - Represents a chaincode function execution that may read and modify the world state.
            CHAINCODE_QUERY - Represents a chaincode function execution that may only read the world state.
            CHAINCODE_TERMINATE - Marks a chaincode as inactive so that future functions of the chaincode can no longer be invoked.
    chaincodeID - The ID of a chaincode which is a hash of the chaincode source, path to the source code, constructor function, and parameters.
    payloadHash - Bytes defining the hash of TransactionPayload.payload.
    metadata - Bytes defining any associated transaction metadata that the application may use.
    uuid - A unique ID for the transaction.
    timestamp - A timestamp of when the transaction request was received by the peer.
    confidentialityLevel - Level of data confidentiality. There are currently 2 levels. Future releases may define more levels.
    nonce - Used for security.
    cert - Certificate of the transactor.
    signature - Signature of the transactor.
    TransactionPayload.payload - Bytes defining the payload of the transaction. As the payload can be large, only the payload hash is included directly in the transaction message.

More detail on transaction security can be found in section 4.
3.1.2.2 Transaction Specification

A transaction is always associated with a chaincode specification which defines the chaincode and the execution environment such as language and security context. Currently there is an implementation that uses Golang for writing chaincode. Other languages may be added in the future.

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

Definition of fields:

    chaincodeID - The chaincode source code path and name.
    ctorMsg - Function name and argument parameters to call.
    timeout - Time in milliseconds to execute the transaction.
    confidentialityLevel - Confidentiality level of this transaction.
    secureContext - Security context of the transactor.
    metadata - Any data the application wants to pass along.

The peer, receiving the chaincodeSpec, wraps it in an appropriate transaction message and broadcasts to the network.
3.1.2.3 Deploy Transaction

Transaction type of a deploy transaction is CHAINCODE_DEPLOY and the payload contains an object of ChaincodeDeploymentSpec.

message ChaincodeDeploymentSpec {
    ChaincodeSpec chaincodeSpec = 1;
    google.protobuf.Timestamp effectiveDate = 2;
    bytes codePackage = 3;
}

Definition of fields:

    chaincodeSpec - See section 3.1.2.2, above.
    effectiveDate - Time when the chaincode is ready to accept invocations.
    codePackage - gzip of the chaincode source.

The validating peers always verify the hash of the codePackage when they deploy the chaincode to make sure the package has not been tampered with since the deploy transaction entered the network.
3.1.2.4 Invoke Transaction

Transaction type of an invoke transaction is CHAINCODE_INVOKE and the payload contains an object of ChaincodeInvocationSpec.

message ChaincodeInvocationSpec {
    ChaincodeSpec chaincodeSpec = 1;
}

3.1.2.5 Query Transaction

A query transaction is similar to an invoke transaction, but the message type is CHAINCODE_QUERY.
3.1.3 Synchronization Messages

Synchronization protocol starts with discovery, described above in section 3.1.1, when a peer realizes that it's behind or its current block is not the same with others. A peer broadcasts either SYNC_GET_BLOCKS, SYNC_STATE_GET_SNAPSHOT, or SYNC_STATE_GET_DELTAS and receives SYNC_BLOCKS, SYNC_STATE_SNAPSHOT, or SYNC_STATE_DELTAS respectively.

The installed consensus plugin (e.g. pbft) dictates how synchronization protocol is being applied. Each message is designed for a specific situation:

SYNC_GET_BLOCKS requests for a range of contiguous blocks expressed in the message payload, which is an object of SyncBlockRange. The correlationId specified is included in the SyncBlockRange of any replies to this message.

message SyncBlockRange {
    uint64 correlationId = 1;
    uint64 start = 2;
    uint64 end = 3;
}

A receiving peer responds with a SYNC_BLOCKS message whose payload contains an object of SyncBlocks

message SyncBlocks {
    SyncBlockRange range = 1;
    repeated Block blocks = 2;
}

The start and end indicate the starting and ending blocks inclusively. The order in which blocks are returned is defined by the start and end values. For example, if start=3 and end=5, the order of blocks will be 3, 4, 5. If start=5 and end=3, the order will be 5, 4, 3.

SYNC_STATE_GET_SNAPSHOT requests for the snapshot of the current world state. The payload is an object of SyncStateSnapshotRequest

message SyncStateSnapshotRequest {
  uint64 correlationId = 1;
}

The correlationId is used by the requesting peer to keep track of the response messages. A receiving peer replies with SYNC_STATE_SNAPSHOT message whose payload is an instance of SyncStateSnapshot

message SyncStateSnapshot {
    bytes delta = 1;
    uint64 sequence = 2;
    uint64 blockNumber = 3;
    SyncStateSnapshotRequest request = 4;
}

This message contains the snapshot or a chunk of the snapshot on the stream, and in which case, the sequence indicate the order starting at 0. The terminating message will have len(delta) == 0.

SYNC_STATE_GET_DELTAS requests for the state deltas of a range of contiguous blocks. By default, the Ledger maintains 500 transition deltas. A delta(j) is a state transition between block(i) and block(j) where i = j-1. The message payload contains an instance of SyncStateDeltasRequest

message SyncStateDeltasRequest {
    SyncBlockRange range = 1;
}

A receiving peer responds with SYNC_STATE_DELTAS, whose payload is an instance of SyncStateDeltas

message SyncStateDeltas {
    SyncBlockRange range = 1;
    repeated bytes deltas = 2;
}

A delta may be applied forward (from i to j) or backward (from j to i) in the state transition.
3.1.4 Consensus Messages

Consensus deals with transactions, so a CONSENSUS message is initiated internally by the consensus framework when it receives a CHAIN_TRANSACTION message. The framework converts CHAIN_TRANSACTION into CONSENSUS then broadcasts to the validating nodes with the same payload. The consensus plugin receives this message and process according to its internal algorithm. The plugin may create custom subtypes to manage consensus finite state machine. See section 3.4 for more details.
3.2 Ledger

The ledger consists of two primary pieces, the blockchain and the world state. The blockchain is a series of linked blocks that is used to record transactions within the ledger. The world state is a key-value database that chaincodes may use to store state when executed by a transaction.
3.2.1 Blockchain
3.2.1.1 Block

The blockchain is defined as a linked list of blocks as each block contains the hash of the previous block in the chain. The two other important pieces of information that a block contains are the list of transactions contained within the block and the hash of the world state after executing all transactions in the block.

message Block {
  version = 1;
  google.protobuf.Timestamp timestamp = 2;
  bytes transactionsHash = 3;
  bytes stateHash = 4;
  bytes previousBlockHash = 5;
  bytes consensusMetadata = 6;
  NonHashData nonHashData = 7;
}

message BlockTransactions {
  repeated Transaction transactions = 1;
}

    version - Version used to track any protocol changes.
    timestamp - The timestamp to be filled in by the block proposer.
    transactionsHash - The merkle root hash of the block's transactions.
    stateHash - The merkle root hash of the world state.
    previousBlockHash - The hash of the previous block.
    consensusMetadata - Optional metadata that the consensus may include in a block.
    nonHashData - A NonHashData message that is set to nil before computing the hash of the block, but stored as part of the block in the database.
    BlockTransactions.transactions - An array of Transaction messages. Transactions are not included in the block directly due to their size.

3.2.1.2 Block Hashing

    The previousBlockHash hash is calculated using the following algorithm.

        Serialize the Block message to bytes using the protocol buffer library.

        Hash the serialized block message to 512 bits of output using the SHA3 SHAKE256 algorithm as described in FIPS 202.

    The transactionHash is the root of the transaction merkle tree. Defining the merkle tree implementation is a TODO.

    The stateHash is defined in section 3.2.2.1.

3.2.1.3 NonHashData

The NonHashData message is used to store block metadata that is not required to be the same value on all peers. These are suggested values.

message NonHashData {
  google.protobuf.Timestamp localLedgerCommitTimestamp = 1;
  repeated TransactionResult transactionResults = 2;
}

message TransactionResult {
  string uuid = 1;
  bytes result = 2;
  uint32 errorCode = 3;
  string error = 4;
}

    localLedgerCommitTimestamp - A timestamp indicating when the block was commited to the local ledger.

    TransactionResult - An array of transaction results.

    TransactionResult.uuid - The ID of the transaction.

    TransactionResult.result - The return value of the transaction.

    TransactionResult.errorCode - A code that can be used to log errors associated with the transaction.

    TransactionResult.error - A string that can be used to log errors associated with the transaction.

3.2.1.4 Transaction Execution

A transaction defines either the deployment of a chaincode or the execution of a chaincode. All transactions within a block are run before recording a block in the ledger. When chaincodes execute, they may modify the world state. The hash of the world state is then recorded in the block.
3.2.2 World State

The world state of a peer refers to the collection of the states of all the deployed chaincodes. Further, the state of a chaincode is represented as a collection of key-value pairs. Thus, logically, the world state of a peer is also a collection of key-value pairs where key consists of a tuple {chaincodeID, ckey}. Here, we use the term key to represent a key in the world state i.e., a tuple {chaincodeID, ckey} and we use the term cKey to represent a unique key within a chaincode.

For the purpose of the description below, chaincodeID is assumed to be a valid utf8 string and ckey and the value can be a sequence of one or more arbitrary bytes.
3.2.2.1 Hashing the world state

During the functioning of a network, many occasions such as committing transactions and synchronizing peers may require computing a crypto-hash of the world state observed by a peer. For instance, the consensus protocol may require to ensure that a minimum number of peers in the network observe the same world state.

Since, computing the crypto-hash of the world state could be an expensive operation, this is highly desirable to organize the world state such that it enables an efficient crypto-hash computation of the world state when a change occurs in the world state. Further, different organization designs may be suitable under different workloads conditions.

Because the fabric is expected to function under a variety of scenarios leading to different workloads conditions, a pluggable mechanism is supported for organizing the world state.
3.2.2.1.1 Bucket-tree

Bucket-tree is one of the implementations for organizing the world state. For the purpose of the description below, a key in the world state is represented as a concatenation of the two components (chaincodeID and ckey) separated by a nil byte i.e., key = chaincodeID+nil+cKey.

This method models a merkle-tree on top of buckets of a hash table in order to compute the crypto-hash of the world state.

At the core of this method, the key-values of the world state are assumed to be stored in a hash-table that consists of a pre-decided number of buckets (numBuckets). A hash function (hashFunction) is employed to determine the bucket number that should contain a given key. Please note that the hashFunction does not represent a crypto-hash method such as SHA3, rather this is a regular programming language hash function that decides the bucket number for a given key.

For modeling the merkle-tree, the ordered buckets act as leaf nodes of the tree - lowest numbered bucket being the left most leaf node in the tree. For constructing the second-last level of the tree, a pre-decided number of leaf nodes (maxGroupingAtEachLevel), starting from left, are grouped together and for each such group, a node is inserted at the second-last level that acts as a common parent for all the leaf nodes in the group. Note that the number of children for the last parent node may be less than maxGroupingAtEachLevel. This grouping method of constructing the next higher level is repeated until the root node of the tree is constructed.

An example setup with configuration {numBuckets=10009 and maxGroupingAtEachLevel=10} will result in a tree with number of nodes at different level as depicted in the following table.
Level   Number of nodes
0   1
1   2
2   11
3   101
4   1001
5   10009

For computing the crypto-hash of the world state, the crypto-hash of each bucket is computed and is assumed to be the crypto-hash of leaf-nodes of the merkle-tree. In order to compute crypto-hash of a bucket, the key-values present in the bucket are first serialized and crypto-hash function is applied on the serialized bytes. For serializing the key-values of a bucket, all the key-values with a common chaincodeID prefix are serialized separately and then appending together, in the ascending order of chaincodeIDs. For serializing the key-values of a chaincodeID, the following information is concatenated:

    Length of chaincodeID (number of bytes in the chaincodeID)
    The utf8 bytes of the chaincodeID
    Number of key-values for the chaincodeID
    For each key-value (in sorted order of the ckey)
        Length of the ckey
        ckey bytes
        Length of the value
        value bytes

For all the numeric types in the above list of items (e.g., Length of chaincodeID), protobuf's varint encoding is assumed to be used. The purpose of the above encoding is to achieve a byte representation of the key-values within a bucket that can not be arrived at by any other combination of key-values and also to reduce the overall size of the serialized bytes.

For example, consider a bucket that contains three key-values namely, chaincodeID1_key1:value1, chaincodeID1_key2:value2, and chaincodeID2_key1:value1. The serialized bytes for the bucket would logically look as - 12 + chaincodeID1 + 2 + 4 + key1 + 6 + value1 + 4 + key2 + 6 + value2 + 12 + chaincodeID2 + 1 + 4 + key1 + 6 + value1

If a bucket has no key-value present, the crypto-hash is considered as nil.

The crypto-hash of an intermediate node and root node are computed just like in a standard merkle-tree i.e., applying a crypto-hash function on the bytes obtained by concatenating the crypto-hash of all the children nodes, from left to right. Further, if a child has a crypto-hash as nil, the crypto-hash of the child is omitted when concatenating the children crypto-hashes. If the node has a single child, the crypto-hash of the child is assumed to be the crypto-hash of the node. Finally, the crypto-hash of the root node is considered as the crypto-hash of the world state.

The above method offers performance benefits for computing crypto-hash when a few key-values change in the state. The major benefits include

    Computation of crypto-hashes of the unchanged buckets can be skipped
    The depth and breadth of the merkle-tree can be controlled by configuring the parameters numBuckets and maxGroupingAtEachLevel. Both depth and breadth of the tree has different implication on the performance cost incurred by and resource demand of different resources (namely - disk I/O, storage, and memory)

In a particular deployment, all the peer nodes are expected to use same values for the configurations numBuckets, maxGroupingAtEachLevel, and hashFunction. Further, if any of these configurations are to be changed at a later stage, the configurations should be changed on all the peer nodes so that the comparison of crypto-hashes across peer nodes is meaningful. Also, this may require to migrate the existing data based on the implementation. For example, an implementation is expected to store the last computed crypto-hashes for all the nodes in the tree which would need to be recalculated.
3.3 Chaincode

Chaincode is an application-level code deployed as a transaction (see section 3.1.2) to be distributed to the network and managed by each validating peer as isolated sandbox. Though any virtualization technology can support the sandbox, currently Docker container is utilized to run the chaincode. The protocol described in this section enables different virtualization support implementation to plug and play.
3.3.1 Virtual Machine Instantiation

A virtual machine implements the VM interface:

type VM interface {
    build(ctxt context.Context, id string, args []string, env []string, attachstdin bool, attachstdout bool, reader io.Reader) error
    start(ctxt context.Context, id string, args []string, env []string, attachstdin bool, attachstdout bool) error
    stop(ctxt context.Context, id string, timeout uint, dontkill bool, dontremove bool) error
}

The fabric instantiates the VM when it processes a Deploy transaction or other transactions on the chaincode while the VM for that chaincode is not running (either crashed or previously brought down due to inactivity). Each chaincode image is built by the build function, started by start and stopped by stop function.

Once the chaincode container is up, it makes a gRPC connection back to the validating peer that started the chaincode, and that establishes the channel for Invoke and Query transactions on the chaincode.
3.3.2 Chaincode Protocol

Communication between a validating peer and its chaincodes is based on a bidirectional gRPC stream. There is a shim layer on the chaincode container to handle the message protocol between the chaincode and the validating peer using protobuf message.

message ChaincodeMessage {

    enum Type {
        UNDEFINED = 0;
        REGISTER = 1;
        REGISTERED = 2;
        INIT = 3;
        READY = 4;
        TRANSACTION = 5;
        COMPLETED = 6;
        ERROR = 7;
        GET_STATE = 8;
        PUT_STATE = 9;
        DEL_STATE = 10;
        INVOKE_CHAINCODE = 11;
        INVOKE_QUERY = 12;
        RESPONSE = 13;
        QUERY = 14;
        QUERY_COMPLETED = 15;
        QUERY_ERROR = 16;
        RANGE_QUERY_STATE = 17;
    }

    Type type = 1;
    google.protobuf.Timestamp timestamp = 2;
    bytes payload = 3;
    string uuid = 4;
}

Definition of fields:

    Type is the type of the message.
    payload is the payload of the message. Each payload depends on the Type.
    uuid is a unique identifier of the message.

The message types are described in the following sub-sections.

A chaincode implements the Chaincode interface, which is called by the validating peer when it processes Deploy, Invoke or Query transactions.

type Chaincode interface {
i   Init(stub *ChaincodeStub, function string, args []string) ([]byte, error)
    Invoke(stub *ChaincodeStub, function string, args []string) ([]byte, error)
    Query(stub *ChaincodeStub, function string, args []string) ([]byte, error)
}

Init, Invoke and Query functions take function and args as parameters to be used by those methods to support a variety of transactions. Init is a constructor function, which will only be invoked by the Deploy transaction. The Query function is not allowed to modify the state of the chaincode; it can only read and calculate the return value as a byte array.
3.3.2.1 Chaincode Deploy

Upon deploy (chaincode container is started), the shim layer sends a one time REGISTER message to the validating peer with the payload containing the ChaincodeID. The validating peer responds with REGISTERED or ERROR on success or failure respectively. The shim closes the connection and exits if it receives an ERROR.

After registration, the validating peer sends INIT with the payload containing a ChaincodeInput object. The shim calls the Init function with the parameters from the ChaincodeInput, enabling the chaincode to perform any initialization, such as setting up the persistent state.

The shim responds with RESPONSE or ERROR message depending on the returned value from the chaincode Init function. If there are no errors, the chaincode initialization is complete and is ready to receive Invoke and Query transactions.
3.3.2.2 Chaincode Invoke

When processing an invoke transaction, the validating peer sends a TRANSACTION message to the chaincode container shim, which in turn calls the chaincode Invoke function, passing the parameters from the ChaincodeInput object. The shim responds to the validating peer with RESPONSE or ERROR message, indicating the completion of the function. If ERROR is received, the payload contains the error message generated by the chaincode.
3.3.2.3 Chaincode Query

Similar to an invoke transaction, when processing a query, the validating peer sends a QUERY message to the chaincode container shim, which in turn calls the chaincode Query function, passing the parameters from the ChaincodeInput object. The Query function may return a state value or an error, which the shim forwards to the validating peer using RESPONSE or ERROR messages respectively.
3.3.2.4 Chaincode State

Each chaincode may define its own persistent state variables. For example, a chaincode may create assets such as TVs, cars, or stocks using state variables to hold the assets attributes. During Invoke function processing, the chaincode may update the state variables, for example, changing an asset owner. A chaincode manipulates the state variables by using the following message types:
PUT_STATE

Chaincode sends a PUT_STATE message to persist a key-value pair, with the payload containing PutStateInfo object.

message PutStateInfo {
    string key = 1;
    bytes value = 2;
}

GET_STATE

Chaincode sends a GET_STATE message to retrieve the value whose key is specified in the payload.
DEL_STATE

Chaincode sends a DEL_STATE message to delete the value whose key is specified in the payload.
RANGE_QUERY_STATE

Chaincode sends a RANGE_QUERY_STATE message to get a range of values. The message payload contains a RangeQueryStateInfo object.

message RangeQueryState {
    string startKey = 1;
    string endKey = 2;
}

The startKey and endKey are inclusive and assumed to be in lexical order. The validating peer responds with RESPONSE message whose payload is a RangeQueryStateResponse object.

message RangeQueryStateResponse {
    repeated RangeQueryStateKeyValue keysAndValues = 1;
    bool hasMore = 2;
    string ID = 3;
}
message RangeQueryStateKeyValue {
    string key = 1;
    bytes value = 2;
}

If hasMore=true in the response, this indicates that additional keys are available in the requested range. The chaincode can request the next set of keys and values by sending a RangeQueryStateNext message with an ID that matches the ID returned in the response.

message RangeQueryStateNext {
    string ID = 1;
}

When the chaincode is finished reading from the range, it should send a RangeQueryStateClose message with the ID it wishes to close.

message RangeQueryStateClose {
  string ID = 1;
}

INVOKE_CHAINCODE

Chaincode may call another chaincode in the same transaction context by sending an INVOKE_CHAINCODE message to the validating peer with the payload containing a ChaincodeSpec object.
QUERY_CHAINCODE

Chaincode may query another chaincode in the same transaction context by sending a QUERY_CHAINCODE message with the payload containing a ChaincodeSpec object.
3.4 Pluggable Consensus Framework

The consensus framework defines the interfaces that every consensus plugin implements:

    consensus.Consenter: interface that allows consensus plugin to receive messages from the network.
    consensus.CPI: Consensus Programming Interface (CPI) is used by consensus plugin to interact with rest of the stack. This interface is split in two parts:
        consensus.Communicator: used to send (broadcast and unicast) messages to other validating peers.
        consensus.LedgerStack: which is used as an interface to the execution framework as well as the ledger.

As described below in more details, consensus.LedgerStack encapsulates, among other interfaces, the consensus.Executor interface, which is the key part of the consensus framework. Namely, consensus.Executor interface allows for a (batch of) transaction to be started, executed, rolled back if necessary, previewed, and potentially committed. A particular property that every consensus plugin needs to satisfy is that batches (blocks) of transactions are committed to the ledger (via consensus.Executor.CommitTxBatch) in total order across all validating peers (see consensus.Executor interface description below for more details).

Currently, consensus framework consists of 3 packages consensus, controller, and helper. The primary reason for controller and helper packages is to avoid "import cycle" in Go (golang) and minimize code changes for plugin to update.

    controller package specifies the consensus plugin used by a validating peer.
    helper package is a shim around a consensus plugin that helps it interact with the rest of the stack, such as maintaining message handlers to other peers.

There are 2 consensus plugins provided: pbft and noops:

    pbft package contains consensus plugin that implements the PBFT [1] consensus protocol. See section 5 for more detail.
    noops is a ''dummy'' consensus plugin for development and test purposes. It doesn't perform consensus but processes all consensus messages. It also serves as a good simple sample to start learning how to code a consensus plugin.

3.4.1 Consenter interface

Definition:

type Consenter interface {
    RecvMsg(msg *pb.Message) error
}

The plugin's entry point for (external) client requests, and consensus messages generated internally (i.e. from the consensus module) during the consensus process. The controller.NewConsenter creates the plugin Consenter. RecvMsg processes the incoming transactions in order to reach consensus.

See helper.HandleMessage below to understand how the peer interacts with this interface.
3.4.2 CPI interface

Definition:

type CPI interface {
    Inquirer
    Communicator
    SecurityUtils
    LedgerStack
}

CPI allows the plugin to interact with the stack. It is implemented by the helper.Helper object. Recall that this object:

    Is instantiated when the helper.NewConsensusHandler is called.
    Is accessible to the plugin author when they construct their plugin's consensus.Consenter object.

3.4.3 Inquirer interface

Definition:

type Inquirer interface {
        GetNetworkInfo() (self *pb.PeerEndpoint, network []*pb.PeerEndpoint, err error)
        GetNetworkHandles() (self *pb.PeerID, network []*pb.PeerID, err error)
}

This interface is a part of the consensus.CPI interface. It is used to get the handles of the validating peers in the network (GetNetworkHandles) as well as details about the those validating peers (GetNetworkInfo):

Note that the peers are identified by a pb.PeerID object. This is a protobuf message (in the protos package), currently defined as (notice that this definition will likely be modified):

message PeerID {
    string name = 1;
}

3.4.4 Communicator interface

Definition:

type Communicator interface {
    Broadcast(msg *pb.Message) error
    Unicast(msg *pb.Message, receiverHandle *pb.PeerID) error
}

This interface is a part of the consensus.CPI interface. It is used to communicate with other peers on the network (helper.Broadcast, helper.Unicast):
3.4.5 SecurityUtils interface

Definition:

type SecurityUtils interface {
        Sign(msg []byte) ([]byte, error)
        Verify(peerID *pb.PeerID, signature []byte, message []byte) error
}

This interface is a part of the consensus.CPI interface. It is used to handle the cryptographic operations of message signing (Sign) and verifying signatures (Verify)
3.4.6 LedgerStack interface

Definition:

type LedgerStack interface {
    Executor
    Ledger
    RemoteLedgers
}

A key member of the CPI interface, LedgerStack groups interaction of consensus with the rest of the fabric, such as the execution of transactions, querying, and updating the ledger. This interface supports querying the local blockchain and state, updating the local blockchain and state, and querying the blockchain and state of other nodes in the consensus network. It consists of three parts: Executor, Ledger and RemoteLedgers interfaces. These are described in the following.
3.4.7 Executor interface

Definition:

type Executor interface {
    BeginTxBatch(id interface{}) error
    ExecTXs(id interface{}, txs []*pb.Transaction) ([]byte, []error)  
    CommitTxBatch(id interface{}, transactions []*pb.Transaction, transactionsResults []*pb.TransactionResult, metadata []byte) error  
    RollbackTxBatch(id interface{}) error  
    PreviewCommitTxBatchBlock(id interface{}, transactions []*pb.Transaction, metadata []byte) (*pb.Block, error)  
}

The executor interface is the most frequently utilized portion of the LedgerStack interface, and is the only piece which is strictly necessary for a consensus network to make progress. The interface allows for a transaction to be started, executed, rolled back if necessary, previewed, and potentially committed. This interface is comprised of the following methods.
3.4.7.1 Beginning a transaction batch

BeginTxBatch(id interface{}) error

This call accepts an arbitrary id, deliberately opaque, as a way for the consensus plugin to ensure only the transactions associated with this particular batch are executed. For instance, in the pbft implementation, this id is the an encoded hash of the transactions to be executed.
3.4.7.2 Executing transactions

ExecTXs(id interface{}, txs []*pb.Transaction) ([]byte, []error)

This call accepts an array of transactions to execute against the current state of the ledger and returns the current state hash in addition to an array of errors corresponding to the array of transactions. Note that a transaction resulting in an error has no effect on whether a transaction batch is safe to commit. It is up to the consensus plugin to determine the behavior which should occur when failing transactions are encountered. This call is safe to invoke multiple times.
3.4.7.3 Committing and rolling-back transactions

RollbackTxBatch(id interface{}) error

This call aborts an execution batch. This will undo the changes to the current state, and restore the ledger to its previous state. It concludes the batch begun with BeginBatchTx and a new one must be created before executing any transactions.

PreviewCommitTxBatchBlock(id interface{}, transactions []*pb.Transaction, metadata []byte) (*pb.Block, error)

This call is most useful for consensus plugins which wish to test for non-deterministic transaction execution. The hashable portions of the block returned are guaranteed to be identical to the block which would be committed if CommitTxBatch were immediately invoked. This guarantee is violated if any new transactions are executed.

CommitTxBatch(id interface{}, transactions []*pb.Transaction, transactionsResults []*pb.TransactionResult, metadata []byte) error

This call commits a block to the blockchain. Blocks must be committed to a blockchain in total order. CommitTxBatch concludes the transaction batch, and a new call to BeginTxBatch must be made before any new transactions are executed and committed.
3.4.8 Ledger interface

Definition:

type Ledger interface {
    ReadOnlyLedger
    UtilLedger
    WritableLedger
}

Ledger interface is intended to allow the consensus plugin to interrogate and possibly update the current state and blockchain. It is comprised of the three interfaces described below.
3.4.8.1 ReadOnlyLedger interface

Definition:

type ReadOnlyLedger interface {
    GetBlock(id uint64) (block *pb.Block, err error)
    GetCurrentStateHash() (stateHash []byte, err error)
    GetBlockchainSize() (uint64, error)
}

ReadOnlyLedger interface is intended to query the local copy of the ledger without the possibility of modifying it. It is comprised of the following functions.

GetBlockchainSize() (uint64, error)

This call returns the current length of the blockchain ledger. In general, this function should never fail, though in the unlikely event that this occurs, the error is passed to the caller to decide what if any recovery is necessary. The block with the highest number will have block number GetBlockchainSize()-1.

Note that in the event that the local copy of the blockchain ledger is corrupt or incomplete, this call will return the highest block number in the chain, plus one. This allows for a node to continue operating from the current state/block even when older blocks are corrupt or missing.

GetBlock(id uint64) (block *pb.Block, err error)

This call returns the block from the blockchain with block number id. In general, this call should not fail, except when the block queried exceeds the current blocklength, or when the underlying blockchain has somehow become corrupt. A failure of GetBlock has a possible resolution of using the state transfer mechanism to retrieve it.

GetCurrentStateHash() (stateHash []byte, err error)

This call returns the current state hash for the ledger. In general, this function should never fail, though in the unlikely event that this occurs, the error is passed to the caller to decide what if any recovery is necessary.
3.4.8.2 UtilLedger interface

Definition:

type UtilLedger interface {
    HashBlock(block *pb.Block) ([]byte, error)
    VerifyBlockchain(start, finish uint64) (uint64, error)
}

UtilLedger interface defines some useful utility functions which are provided by the local ledger. Overriding these functions in a mock interface can be useful for testing purposes. This interface is comprised of two functions.

HashBlock(block *pb.Block) ([]byte, error)

Although *pb.Block has a GetHash method defined, for mock testing, overriding this method can be very useful. Therefore, it is recommended that the GetHash method never be directly invoked, but instead invoked via this UtilLedger.HashBlock interface. In general, this method should never fail, but the error is still passed to the caller to decide what if any recovery is appropriate.

VerifyBlockchain(start, finish uint64) (uint64, error)

This utility method is intended for verifying large sections of the blockchain. It proceeds from a high block start to a lower block finish, returning the block number of the first block whose PreviousBlockHash does not match the block hash of the previous block as well as an error. Note, this generally indicates the last good block number, not the first bad block number.
3.4.8.3 WritableLedger interface

Definition:

type WritableLedger interface {
    PutBlock(blockNumber uint64, block *pb.Block) error
    ApplyStateDelta(id interface{}, delta *statemgmt.StateDelta) error
    CommitStateDelta(id interface{}) error
    RollbackStateDelta(id interface{}) error
    EmptyState() error
}

WritableLedger interface allows for the caller to update the blockchain. Note that this is NOT intended for use in normal operation of a consensus plugin. The current state should be modified by executing transactions using the Executor interface, and new blocks will be generated when transactions are committed. This interface is instead intended primarily for state transfer or corruption recovery. In particular, functions in this interface should NEVER be exposed directly via consensus messages, as this could result in violating the immutability promises of the blockchain concept. This interface is comprised of the following functions.

- PutBlock(blockNumber uint64, block *pb.Block) error

This function takes a provided, raw block, and inserts it into the blockchain at the given blockNumber. Note that this intended to be an unsafe interface, so no error or sanity checking is performed. Inserting a block with a number higher than the current block height is permitted, similarly overwriting existing already committed blocks is also permitted. Remember, this does not affect the auditability or immutability of the chain, as the hashing techniques make it computationally infeasible to forge a block earlier in the chain. Any attempt to rewrite the blockchain history is therefore easily detectable. This is generally only useful to the state transfer API.

- ApplyStateDelta(id interface{}, delta *statemgmt.StateDelta) error

This function takes a state delta, and applies it to the current state. The delta will be applied to transition a state forward or backwards depending on the construction of the state delta. Like the `Executor` methods, `ApplyStateDelta` accepts an opaque interface `id` which should also be passed into `CommitStateDelta` or `RollbackStateDelta` as appropriate.

- CommitStateDelta(id interface{}) error

This function commits the state delta which was applied in `ApplyStateDelta`. This is intended to be invoked after the caller to `ApplyStateDelta` has verified the state via the state hash obtained via `GetCurrentStateHash()`. This call takes the same `id` which was passed into `ApplyStateDelta`.

- RollbackStateDelta(id interface{}) error

This function unapplies a state delta which was applied in `ApplyStateDelta`. This is intended to be invoked after the caller to `ApplyStateDelta` has detected the state hash obtained via `GetCurrentStateHash()` is incorrect. This call takes the same `id` which was passed into `ApplyStateDelta`.

- EmptyState() error

This function will delete the entire current state, resulting in a pristine empty state. It is intended to be called before loading an entirely new state via deltas. This is generally only useful to the state transfer API.

3.4.9 RemoteLedgers interface

Definition:

type RemoteLedgers interface {
    GetRemoteBlocks(peerID uint64, start, finish uint64) (<-chan *pb.SyncBlocks, error)
    GetRemoteStateSnapshot(peerID uint64) (<-chan *pb.SyncStateSnapshot, error)
    GetRemoteStateDeltas(peerID uint64, start, finish uint64) (<-chan *pb.SyncStateDeltas, error)
}

The RemoteLedgers interface exists primarily to enable state transfer and to interrogate the blockchain state at other replicas. Just like the WritableLedger interface, it is not intended to be used in normal operation and is designed to be used for catchup, error recovery, etc. For all functions in this interface it is the caller's responsibility to enforce timeouts. This interface contains the following functions.

    GetRemoteBlocks(peerID uint64, start, finish uint64) (<-chan *pb.SyncBlocks, error)

    This function attempts to retrieve a stream of *pb.SyncBlocks from the peer designated by peerID for the range from start to finish. In general, start should be specified with a higher block number than finish, as the blockchain must be validated from end to beginning. The caller must validate that the desired block is being returned, as it is possible that slow results from another request could appear on this channel. Invoking this call for the same peerID a second time will cause the first channel to close.

    GetRemoteStateSnapshot(peerID uint64) (<-chan *pb.SyncStateSnapshot, error)

    This function attempts to retrieve a stream of *pb.SyncStateSnapshot from the peer designated by peerID. To apply the result, the existing state should first be emptied via the WritableLedger EmptyState call, then the contained deltas in the stream should be applied sequentially.

      GetRemoteStateDeltas(peerID uint64, start, finish uint64) (<-chan *pb.SyncStateDeltas, error)

    This function attempts to retrieve a stream of *pb.SyncStateDeltas from the peer designated by peerID for the range from start to finish. The caller must validated that the desired block delta is being returned, as it is possible that slow results from another request could appear on this channel. Invoking this call for the same peerID a second time will cause the first channel to close.

3.4.10 controller package
3.4.10.1 controller.NewConsenter

Signature:

func NewConsenter(cpi consensus.CPI) (consenter consensus.Consenter)

This function reads the peer.validator.consensus value in core.yaml configuration file, which is the configuration file for the peer process. The value of the peer.validator.consensus key defines whether the validating peer will run with the noops consensus plugin or the pbft one. (Notice that this should eventually be changed to either noops or custom. In case of custom, the validating peer will run with the consensus plugin defined in consensus/config.yaml.)

The plugin author needs to edit the function's body so that it routes to the right constructor for their package. For example, for pbft we point to the obcpft.GetPlugin constructor.

This function is called by helper.NewConsensusHandler when setting the consenter field of the returned message handler. The input argument cpi is the output of the helper.NewHelper constructor and implements the consensus.CPI interface.
3.4.11 helper package
3.4.11.1 High-level overview

A validating peer establishes a message handler (helper.ConsensusHandler) for every connected peer, via the helper.NewConsesusHandler function (a handler factory). Every incoming message is inspected on its type (helper.HandleMessage); if it's a message for which consensus needs to be reached, it's passed on to the peer's consenter object (consensus.Consenter). Otherwise it's passed on to the next message handler in the stack.
3.4.11.2 helper.ConsensusHandler

Definition:

type ConsensusHandler struct {
    chatStream  peer.ChatStream
    consenter   consensus.Consenter
    coordinator peer.MessageHandlerCoordinator
    done        chan struct{}
    peerHandler peer.MessageHandler
}

Within the context of consensus, we focus only on the coordinator and consenter fields. The coordinator, as the name implies, is used to coordinate between the peer's message handlers. This is, for instance, the object that is accessed when the peer wishes to Broadcast. The consenter receives the messages for which consensus needs to be reached and processes them.

Notice that fabric/peer/peer.go defines the peer.MessageHandler (interface), and peer.MessageHandlerCoordinator (interface) types.
3.4.11.3 helper.NewConsensusHandler

Signature:

func NewConsensusHandler(coord peer.MessageHandlerCoordinator, stream peer.ChatStream, initiatedStream bool, next peer.MessageHandler) (peer.MessageHandler, error)

Creates a helper.ConsensusHandler object. Sets the same coordinator for every message handler. Also sets the consenter equal to: controller.NewConsenter(NewHelper(coord))
3.4.11.4 helper.Helper

Definition:

type Helper struct {
    coordinator peer.MessageHandlerCoordinator
}

Contains the reference to the validating peer's coordinator. Is the object that implements the consensus.CPI interface for the peer.
3.4.11.5 helper.NewHelper

Signature:

func NewHelper(mhc peer.MessageHandlerCoordinator) consensus.CPI

Returns a helper.Helper object whose coordinator is set to the input argument mhc (the coordinator field of the helper.ConsensusHandler message handler). This object implements the consensus.CPI interface, thus allowing the plugin to interact with the stack.
3.4.11.6 helper.HandleMessage

Recall that the helper.ConsesusHandler object returned by helper.NewConsensusHandler implements the peer.MessageHandler interface:

type MessageHandler interface {
    RemoteLedger
    HandleMessage(msg *pb.Message) error
    SendMessage(msg *pb.Message) error
    To() (pb.PeerEndpoint, error)
    Stop() error
}

Within the context of consensus, we focus only on the HandleMessage method. Signature:

func (handler *ConsensusHandler) HandleMessage(msg *pb.Message) error

The function inspects the Type of the incoming Message. There are four cases:

    Equal to pb.Message_CONSENSUS: passed to the handler's consenter.RecvMsg function.
    Equal to pb.Message_CHAIN_TRANSACTION (i.e. an external deployment request): a response message is sent to the user first, then the message is passed to the consenter.RecvMsg function.
    Equal to pb.Message_CHAIN_QUERY (i.e. a query): passed to the helper.doChainQuery method so as to get executed locally.
    Otherwise: passed to the HandleMessage method of the next handler down the stack.

3.5 Events

The event framework provides the ability to generate and consume predefined and custom events. There are 3 basic components:

    Event stream
    Event adapters
    Event structures

3.5.1 Event Stream

An event stream is a gRPC channel capable of sending and receiving events. Each consumer establishes an event stream to the event framework and expresses the events that it is interested in. the event producer only sends appropriate events to the consumers who have connected to the producer over the event stream.

The event stream initializes the buffer and timeout parameters. The buffer holds the number of events waiting for delivery, and the timeout has 3 options when the buffer is full:

    If timeout is less than 0, drop the newly arriving events
    If timeout is 0, block on the event until the buffer becomes available
    If timeout is greater than 0, wait for the specified timeout and drop the event if the buffer remains full after the timeout

3.5.1.1 Event Producer

The event producer exposes a function to send an event, Send(e *pb.Event), where Event is either a pre-defined Block or a Generic event. More events will be defined in the future to include other elements of the fabric.

message Generic {
    string eventType = 1;
    bytes payload = 2;
}

The eventType and payload are freely defined by the event producer. For example, JSON data may be used in the payload. The Generic event may also be emitted by the chaincode or plugins to communicate with consumers.
3.5.1.2 Event Consumer

The event consumer enables external applications to listen to events. Each event consumer registers an event adapter with the event stream. The consumer framework can be viewed as a bridge between the event stream and the adapter. A typical use of the event consumer framework is:

adapter = <adapter supplied by the client application to register and receive events>
consumerClient = NewEventsClient(<event consumer address>, adapter)
consumerClient.Start()
...
...
consumerClient.Stop()

3.5.2 Event Adapters

The event adapter encapsulates three facets of event stream interaction:

    an interface that returns the list of all events of interest
    an interface called by the event consumer framework on receipt of an event
    an interface called by the event consumer framework when the event bus terminates

The reference implementation provides Golang specific language binding.

      EventAdapter interface {
         GetInterestedEvents() ([]*ehpb.Interest, error)
         Recv(msg *ehpb.Event) (bool,error)
         Disconnected(err error)
      }

Using gRPC as the event bus protocol allows the event consumer framework to be ported to different language bindings without affecting the event producer framework.
3.5.3 Event Structure

This section details the message structures of the event system. Messages are described directly in Golang for simplicity.

The core message used for communication between the event consumer and producer is the Event.

    message Event {
        oneof Event {
            //consumer events
            Register register = 1;

            //producer events
            Block block = 2;
            Generic generic = 3;
       }
    }

Per the above definition, an event has to be one of Register, Block or Generic.

As mentioned in the previous sections, a consumer creates an event bus by establishing a connection with the producer and sending a Register event. The Register event is essentially an array of Interest messages declaring the events of interest to the consumer.

    message Interest {
        enum ResponseType {
            //don't send events (used to cancel interest)
            DONTSEND = 0;
            //send protobuf objects
            PROTOBUF = 1;
            //marshall into JSON structure
            JSON = 2;
        }
        string eventType = 1;
        ResponseType responseType = 2;
    }

Events can be sent directly as protobuf structures or can be sent as JSON structures by specifying the responseType appropriately.

Currently, the producer framework can generate a Block or a Generic event. A Block is a message used for encapsulating properties of a block in the blockchain.



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
+ noops 插件是什么？
+ Multichain - 多链
