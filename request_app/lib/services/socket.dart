import 'package:socket_io_client/socket_io_client.dart' as IO;
import "package:request_app/variables.dart" as variables;
class SocketService {
  late IO.Socket socket;

  void connectToServer() {
    socket = IO.io(variables.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to server: ${socket.id}');
      socket.emit('join_room', 'general');
    });

    socket.on('message', (data) {
      print('Message received: $data');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void sendMessage(String message) {
    socket.emit('message', message);
  }
}