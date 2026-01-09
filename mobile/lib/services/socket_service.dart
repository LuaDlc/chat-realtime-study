import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  late IO.Socket _socket;

  final String _baseUrl = 'http://10.0.2.2:3000'; //ios: http://localhost:3000

  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void initConnection() {
    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket.connect();
    _setupListeners();
  }

  void _setupListeners() {
    _socket.onConnect((_) {
      print('conectado ao backend');
      _isConnected = true;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      print('desconectado');
      _isConnected = false;
      notifyListeners();
    });

    _socket.on('previous_messages', (data) {
      if (data is List) {
        _messages = List<Map<String, dynamic>>.from(data);
        notifyListeners();
      }
    });

    _socket.on('receive_message', (data) {
      _messages.add(Map<String, dynamic>.from(data));
      notifyListeners();
    });
  }

  void sendMessage(String text, String user) {
    _socket.emit('send_message', {'texto': text, 'usuario': user});
  }

  void disconnect() {
    _socket.disconnect();
  }
}
