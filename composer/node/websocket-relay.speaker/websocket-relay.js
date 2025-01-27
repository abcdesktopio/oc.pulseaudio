// source froml https://github.com/phoboslab/jsmpeg
//
// Use the websocket-relay to serve a raw MPEG-TS over WebSockets. You can use
// ffmpeg to feed the relay. ffmpeg -> websocket-relay -> browser
// Example:
// node websocket-relay yoursecret 8081 8082
// ffmpeg -i <some input> -f mpegts http://localhost:8081/yoursecret

var fs = require('fs'),
	WebSocket = require('ws'),
	supervisord = require('supervisord');

if (process.argv.length < 2) {
	console.log(
		'Usage: \n' +
		'node websocket-relay.js <fifofilename> [<websocket-port>]'
	);
	process.exit();
}

var FIFO_FILENAME = process.argv[2]  || '/container/speaker',
    WEBSOCKET_PORT = process.argv[3] || 8082;


// supervisord
// connect supervisord_client to the unix://var/run/desktop/supervisor.sock
var supervisord_client = supervisord.connect('unix://var/run/desktop/supervisor.sock');

// process.env.SPAWNER_SERVICE_TCP_PORT
// Websocket Server
const host = process.env.CONTAINER_IP_ADDR || '0.0.0.0';
console.log( "listening on host=", host );

var socketServer = new WebSocket.Server({ host: host, port: WEBSOCKET_PORT, perMessageDeflate: false});
socketServer.connectionCount = 0;
socketServer.on('connection', function(socket, upgradeReq) {

	
	if (socketServer.connectionCount === 0) {
		// start ffmpeg 
		console.log( 'connectionCount == 0, starting ffmpeg' );
		supervisord_client.startProcess(
			'ffmpeg.speaker', 
			function(err, result) { 
				if (err) console.log(err);
				if (result) console.log(result); 
			}
		);
	}
	
	socketServer.connectionCount++;
	console.log( "socketServer.connectionCount=", socketServer.connectionCount );
	console.log(
		'New WebSocket Connection: ',
		(upgradeReq || socket.upgradeReq).socket.remoteAddress,
		(upgradeReq || socket.upgradeReq).headers['user-agent'],
		'('+socketServer.connectionCount+' total)'
	);
	socket.on('close', function(code, message){
		socketServer.connectionCount--;
		console.log(
			'Disconnected WebSocket ('+socketServer.connectionCount+' total)'
		);
		
		if (socketServer.connectionCount === 0) {
			// stop ffmpeg
                	console.log( 'connectionCount == 0, stoping ffmpeg' );
                	supervisord_client.stopProcess(
                        	'ffmpeg',
                        	function(err, result) {
                                	if (err) console.log(err);
                                	if (result) console.log(result);
                        	}
                	);
        	}
		
	});
});

console.log('Reading fifo file:' + FIFO_FILENAME);
const fifo = fs.createReadStream(FIFO_FILENAME);
fifo.on('data', broadcast );

function broadcast(data) {
	socketServer.clients.forEach(function each(client) {
		if (client.readyState === WebSocket.OPEN) {
			client.send(data);
		}
	});
};

console.log('Awaiting WebSocket connections on ws://' + host + ':' + WEBSOCKET_PORT + '/');
