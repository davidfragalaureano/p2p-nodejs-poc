### Setup
```shell
npm install
```

### How to run

Command:
```shell
node peer.js HOST:PORT [list of peers HOST:PORT]
```

### Sample

Node 1 (terminal 1):
```shell
node peer.js localhost:10001 localhost:10002 localhost:10003 localhost:10004
```

Node 2 (terminal 2):
```shell
node peer.js localhost:10002 localhost:10001 localhost:10003 localhost:10004
```

Node 3 (terminal 3):
```shell
node peer.js localhost:10003 localhost:10001 localhost:10002 localhost:10004
```

Node 4 (terminal 4):
```shell
node peer.js localhost:10004 localhost:10001 localhost:10002 localhost:10003
```

### Running on Docker

We create a way to `create/remove` nodes dinamically inside a docker network. 

#### Adding node

Before running a node, you need to build the docker image of a node-peer (you can change it by your own)

`docker build -t node-peer .`

Now you can run nodes

`make node-1/up`

If everything goes well, you can see the logs of any `node-x` and you will see all running nodes are connected and `broadcasting` a message to all peers.
I you add more, they will connect to the existing ones.

```bash
david.fraga@Davids-MacBook-Pro ~/Desktop/rootstock
$ docker logs node-1 -f
[a friend joined]: node-2:8080
[a friend joined]: node-3:8080
[ node-2:8080 ] : is Active and connected.
[ node-3:8080 ] : is Active and connected.
[ node-3:8080 ] : is Active and connected.
[ node-2:8080 ] : is Active and connected.
[ node-2:8080 ] : is Active and connected.
[ node-3:8080 ] : is Active and connected.
```

#### Stopping node

`make node-1/down` 

#### Stopping all nodes

`make down`

#### Remove all nodes

`make clean`

