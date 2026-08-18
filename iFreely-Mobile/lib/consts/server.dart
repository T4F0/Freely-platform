import 'package:socket_io_client/socket_io_client.dart' as IO;




const SERVER = "http://192.168.159.156:8000";
const GRAPHQL_SERVER = "http://192.168.159.156:8000/graphql";
const MESSAGING_SERVER = "http://192.168.159.156:8080";




class Socket {
  Socket._();
  
  final IO.Socket io = IO.io(MESSAGING_SERVER, <String, dynamic>{
    'transports': ['websocket'],
    "autoConnect": false,
  });

  static final Socket ws = Socket._();

  factory Socket() {
    return ws;
  }
}