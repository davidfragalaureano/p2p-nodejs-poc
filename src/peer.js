const P2P = require('./p2p.js');
const me = process.argv[2];
const peers = process.argv.slice(3);

const friends = {}

const swarm = new P2P(me, peers);

swarm.on('connection', (socket, peerId) => {
    console.log('[a friend joined]:', peerId)
    friends[peerId] = socket;
    socket.on('data', data => {
        console.log(data.toString().trim());
    })
    broadcast();
})

process.stdin.on('data', data => {
    Object.values(friends).forEach(friend => {
        friend.write(data)
    })
});

async function broadcast(){
    // eslint-disable-next-line no-constant-condition
    while(true) { 
        await sleep(10000);
        Object.values(friends).forEach(friend => {
            friend.write(`[ ${me} ] : is Active and connected.`);
        })
    }
}

async function sleep(ms) {
   return await new Promise(resolve => setTimeout(resolve, ms));
}
