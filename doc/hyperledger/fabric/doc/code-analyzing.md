项目地址
https://github.com/hyperledger/fabric

peer 主程序

第三方程序框架

cli 应用开发框架  
https://github.com/spf13/cobra  
可提供简单的命令，参数的解析和对应操作的调用；智能建议；自动化的帮助信息等等。

配置文件读取解析框架  
https://github.com/spf13/viper  
可读取多种格式的配置文件，多种配置源（如：文件，远程配置，环境变量等），并能够监控配置文件并更新等等。

peer node start 执行入口？  
https://github.com/hyperledger/fabric/blob/master/peer/node/start.go

共识协议接口定义  
https://github.com/hyperledger/fabric/blob/master/consensus/consensus.go

pbft  
https://github.com/hyperledger/fabric/blob/master/consensus/pbft/pbft.go

block 定义  
https://github.com/hyperledger/fabric/blob/master/protos/fabric.pb.go  
```
// Block carries The data that describes a block in the blockchain.
// version - Version used to track any protocol changes.
// timestamp - The time at which the block or transaction order
// was proposed. This may not be used by all consensus modules.
// transactions - The ordered list of transactions in the block.
// stateHash - The state hash after running transactions in this block.
// previousBlockHash - The hash of the previous block in the chain.
// consensusMetadata - Consensus modules may optionally store any
// additional metadata in this field.
// nonHashData - Data stored with the block, but not included in the blocks
// hash. This allows this data to be different per peer or discarded without
// impacting the blockchain.
type Block struct {
    Version           uint32                     `protobuf:"varint,1,opt,name=version" json:"version,omitempty"`
    Timestamp         *google_protobuf.Timestamp `protobuf:"bytes,2,opt,name=timestamp" json:"timestamp,omitempty"`
    Transactions      []*Transaction             `protobuf:"bytes,3,rep,name=transactions" json:"transactions,omitempty"`
    StateHash         []byte                     `protobuf:"bytes,4,opt,name=stateHash,proto3" json:"stateHash,omitempty"`
    PreviousBlockHash []byte                     `protobuf:"bytes,5,opt,name=previousBlockHash,proto3" json:"previousBlockHash,omitempty"`
    ConsensusMetadata []byte                     `protobuf:"bytes,6,opt,name=consensusMetadata,proto3" json:"consensusMetadata,omitempty"`
    NonHashData       *NonHashData               `protobuf:"bytes,7,opt,name=nonHashData" json:"nonHashData,omitempty"`
}

// Contains information about the blockchain ledger such as height, current
// block hash, and previous block hash.
type BlockchainInfo struct {
    Height            uint64 `protobuf:"varint,1,opt,name=height" json:"height,omitempty"`
    CurrentBlockHash  []byte `protobuf:"bytes,2,opt,name=currentBlockHash,proto3" json:"currentBlockHash,omitempty"`
    PreviousBlockHash []byte `protobuf:"bytes,3,opt,name=previousBlockHash,proto3" json:"previousBlockHash,omitempty"`
}
```

```
获取BlockchainInfo 数据
curl http://172.28.111.2:5000/chain

获取Block 数据
curl http://172.28.111.2:5000/chain/blocks/0
curl http://172.28.111.2:5000/chain/blocks/1
curl http://172.28.111.2:5000/chain/blocks/3
{
    "transactions":[
        {
            "type":1,
            "chaincodeID":"***",
            "payload":"***",
            "uuid":"***",
            "timestamp":{"seconds":1472709297,"nanos":661674530}
        }
    ],
    "previousBlockHash":"***",
    "nonHashData":{
        "localLedgerCommitTimestamp":{
            "seconds":1472710240,
            "nanos":351332823
        }
    }
}
```

两个概念定义：block height/blockchain height  
http://bitcoin.stackexchange.com/questions/18561/definition-of-blockchain-height

ReadOnlyLedger 接口可以获取区块链大小（长度？）
https://github.com/hyperledger/fabric/blob/master/consensus/consensus.go
```
// ReadOnlyLedger is used for interrogating the blockchain
type ReadOnlyLedger interface {
    GetBlock(id uint64) (block *pb.Block, err error)
    GetBlockchainSize() uint64
    GetBlockchainInfo() *pb.BlockchainInfo
    GetBlockchainInfoBlob() []byte
    GetBlockHeadMetadata() ([]byte, error)
}
```

fabric 项目自带的db 工具  
https://github.com/hyperledger/fabric/blob/master/tools/dbutility/README.md
```
cd $GOPATH/src/github.com/hyperledger/fabric/tools/dbutility
go build

./dbutility -dbDir /var/hyperledger/production/
```

fabric 项目自带测试应用?busywork  
需要安装tcl http://core.tcl.tk/  
```
yum install tcl tcllib tclx
```

block 计算hash https://godoc.org/golang.org/x/crypto/sha3

源码分析博客  
http://blog.csdn.net/pangjiuzala/article/details/51043980

