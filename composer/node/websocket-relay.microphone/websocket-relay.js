// source froml https://github.com/phoboslab/jsmpeg
//
// Use the websocket-relay to serve a raw MPEG-TS over WebSockets. You can use
// ffmpeg to feed the relay. ffmpeg -> websocket-relay -> browser
// Example:
// node websocket-relay yoursecret 8081 8082
// ffmpeg -i <some input> -f mpegts http://localhost:8081/yoursecret

// set $microphone_service_tcp_port        29789;

var fs = require('fs'),
    WebSocket = require('ws');

if (process.argv.length < 2) {
        console.log(
                'Usage: \n' +
                'node websocket-relay.js <fifofilename> [<websocket-port>]'
        );
        process.exit();
}

var FIFO_FILENAME = process.argv[2]  || '/container/microphone',
    WEBSOCKET_PORT = process.argv[3] || 8082;

// supervisord
// connect supervisord_client to the unix://var/run/desktop/supervisor.sock
// var supervisord_client = supervisord.connect('unix://var/run/desktop/supervisor.sock');

// process.env.SPAWNER_SERVICE_TCP_PORT
// Websocket Server
const host = process.env.CONTAINER_IP_ADDR || '0.0.0.0';
console.log( "listening on host=", host );

function create_pulseaudio_microphone() {
  const command = 'pactl';
  const args = [ 'load-module', 'module-pipe-source', 'source_name=microphone',  'file=' + FIFO_FILENAME, 'source_properties=device.description=virtual_microphone', 'format=float32le', 'rate=44100', 'channels=1' ];
  try {
    const pactl_process = child_process.spawnSync(command, args,  { encoding : 'utf8' });
  } catch (err) {
    if (err.code) {
         // Spawning child process failed
         console.error(err.code);
    } else {
      // Child was spawned but exited with non-zero exit code
      // Error contains any stdout and stderr from the child
      const { stdout, stderr } = err;
             console.error({ stdout, stderr });
      }
  }
  return fs.existsSync(FIFO_FILENAME);
}

function first_connection() {
  // create pulseaudio module fifo
  // wait for fifo file
  const bCreate = create_pulseaudio_microphone();
  if (!bCreate)
    console.error( FIFO_FILENAME + ' is not created');
}


var socketServer = new WebSocket.Server({ host: host, port: WEBSOCKET_PORT, perMessageDeflate: false});
socketServer.connectionCount = 0;
socketServer.on('connection', function(socket, upgradeReq) {
	if (socketServer.connectionCount === 0) {
		// start ffmpeg 
		console.log( 'connectionCount == 0, starting ffmpeg' );
		// first_connection();
		console.log('Writing fifo file:' + FIFO_FILENAME);
		fifo = fs.createWriteStream(FIFO_FILENAME);
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
			fifo.close();
			fifo = null;
        	}
	});

	socket.on('message', (message) => {
  		// Code to handle incoming messages
		// console.log('message from websocket');
		//console.log(message);
  		if (fifo)
        		fifo.write( message );
  		else
        		console.log( 'fifo is null');
	});
});

console.log('Awaiting WebSocket connections on ws://' + host + ':' + WEBSOCKET_PORT + '/');
