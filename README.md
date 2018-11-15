# bmttool

BenchMark Test Tool

Program to test ethereum based blockchain performance.

## Download/Install

    git clone https://github.com/boraecosystem/bmttool
    cd bmttool
    make

## Usage

You can see usage if you run `bmttool` binary without any parameters.

    ./bin/bmttool

    Usage: bmttool [options...] [deploy <contract.(js|.json)>+ |
        kv-count | kv-put <key> <value> | kv-get <key> |
        bulk-kv-put <prefix> <start> <end> [<batch>] ]

    options:
    -a <password> <account-file>: an ethereum account file and password: ETH_ACCOUNT.
        -:	read from stdin
        @<file-name>:	password is in <file-name> file
    -c <contract-address>:	if not specified, env. var. ETH_CONTRACT.
    -g <gas>  :	gas amount
    -p <gas-price>: gas price
    -i <abi>  :	ABI in .json or .js file, if not specified, env. var. ETH_ABI.
    -s <url>  :	geth url. ETH_URL.
    -d <delay>:	delay between trxs (microsecond)
    -t <count>:	number of workers
    -q        :	silent

## Test

To test, you need to deploy a key-value store Contract. Then you can put/get/count key-value pairs as following way.

### Prerequisites

You need an account to deploy a contract and send transactions.
Copy the keystore file of account to working directory.

##### Example
    cp ~/Library/Ethereum/keystore/<keystore file> ./account-1

### Deploy Smart Contract

There is a key-value store Contract for testing.
Please refer to `contracts/kv-store.sol` file.

##### Usage
    bmttool -a <password> <account-file> -s <geth url> -g <gas> deploy <contract.js>

##### Example
    ./bin/bmttool -a "1" account-1 -s http://localhost:8501 -g 1000000 \
    deploy ./kv-store.js

##### Result
    Contract mined! address: 0x5Bd2B290d9CbF0979281722a6f7c73C21cBEA6c5 transactionHash: 0xe66ceab1f4642fad91537fb89b966f146106c3eccfcd7b257121dca1a64b5a86

Remember the contract address above for later usage.

### Put a key-value pair

You can store a key-value pair on the contract.

##### Usage
    bmttool -a <password> <account-file> -s <geth url> -g <gas> \
    -i <contract.js> -c <contract-address> kv-put <key> <value>

##### Example
    ./bin/bmttool -a "1" account-1 -s http://localhost:8501 -g 100000 \
    -i ./kv-store.js -c 0x5Bd2B290d9CbF0979281722a6f7c73C21cBEA6c5 kv-put a 10

##### Result
    Hash 0xc2aa315ddd80bf82f88da98c893779513475b30c218ceb9c7c1b550c6753d474

### Get a key-value pair

You can get a value of given key from the contract.

##### Usage
    bmttool -a <password> <account-file> -s <geth url> \
    -i <contract.js> -c <contract-address> kv-get <key>

##### Example
    ./bin/bmttool -a "1" account-1 -s http://localhost:8501 \
    -i ./kv-store.js -c 0x5Bd2B290d9CbF0979281722a6f7c73C21cBEA6c5 kv-get a

##### Result
    10

### Get key-value count

You can get the count of key-value pairs from the contract.

##### Usage
    bmttool -a <password> <account-file> -s <geth url> \
    -i <contract.js> -c <contract-address> kv-count

##### Example
    ./bin/bmttool -a "1" account-1 -s http://localhost:8501 \
    -i ./kv-store.js -c 0x5Bd2B290d9CbF0979281722a6f7c73C21cBEA6c5 kv-count

##### Result
    1

### Put bulk key-value pairs (TPS measurement purpose)

You can put multiple key-value pairs asynchronously.

##### Usage
    bmttool -a <password> <account-file> -s <geth url> -g <gas> \
    -i <contract.js> -c <contract-address> bulk-kv-put <prefix> <start> <end> [<batch>]

##### Example
    ./bin/bmttool -a "1" account-1 -s http://localhost:8501 -g 100000 \
    -i ./kv-store.js -c 0x5Bd2B290d9CbF0979281722a6f7c73C21cBEA6c5 bulk-kv-put b 1 10

##### Result
    1: 0x4bb037712814b0d1c5ab74fe0d387caca5156253b21952aed713bdacd667e4d1
    2: 0x526bd625bef43948625d3d2724c99b916807f927f33c773a76a0f9b5bbff7c58
    3: 0x5c40db6788f9815579bf5e70082d97a31a347b1f4d56ef91a45f42f7554eb22f
    4: 0x8d677dde8cd194874e3749d94fce17032f59fa19ffc0d4a898a30fb45e99ad94
    5: 0x1405bcd1bf9e5069d844c23907d396a58c6de65222159a4ea43fe6b9727d87fa
    6: 0x9a5442361b768afd7bca165b2e08572aef82aac6a582880e5b0776b0c55778c1
    7: 0x4d79a8a4e399ed4581a3083bc85ec06bc182d46730fe1438aba3c7dec0a4c38b
    8: 0x8107cd206c3d2f4b88907a513702f083f820c110deb5b9a0795caa75b011ea24
    9: 0xf7b9331fe9cc6e0c1b7f99fb8284c90abe6a7e18850b5d976e97231da3ca36d7
    10: 0x947b0f7e0f68355a85ec3ad74ffe487afcdab0e9dad1313c92ba5b5b89b7d89e
    Checking last tx 0x947b0f7e0f68355a85ec3ad74ffe487afcdab0e9dad1313c92ba5b5b89b7d89e....done.
    Took 10 / 1.521 = 6.575 tps

In this way, stored key-value pairs are from `key : <key>-1, value : <key>-1-data` to `key : <key>-10, value : <key>-10-data`.
That is, from `key : b-1, value : b-1-data` to `key : b-10, value : b-10-data`.

## TPS(transactions per second) Test

You can test performance through putting bulk key-value pairs.
Please adjust delay (-d option) and threads (-t option) to send moderate transactions.

##### Example
    ./bin/bmttool -a "1" account-1 -s http://localhost:8501 -g 100000 \
    -i ./kv-store.js -c 0x5Bd2B290d9CbF0979281722a6f7c73C21cBEA6c5 \
    bulk-kv-put b 1 10000 -d 100 -t 2 bulk-kv-put c 1 10000

##### Result
    1: 0x23acdd5c89ba6db8977a667d6e80f299488d2b61ddb9b6cecb594cefdfb8318b
    2: 0xbe130400b2646189aa68ddb9f712d395d2710e80c4f416575b81a2cc697d4712
    3: 0x638bae60fae232c7d3cb8d44d073f615c8028635ef979dd58ccf59a699137a14
    ...
    9998: 0xa0d0691f599b1e077f133730fa05508fe1c4d718f0c6997935e8791a40ad8298
    9999: 0x96c0fd507cf50dc5c11ec77c2905feb1b859f36d527eea3a3a4594525849c778
    10000: 0xc3197b6010f9a34b8a040ecc07412974b5d305ff68bca77ae2b4bf0a72a8dc46
    Checking last tx 0xc3197b6010f9a34b8a040ecc07412974b5d305ff68bca77ae2b4bf0a72a8dc46....done.
    Took 10000 / 7.266 = 1376.273 tps
