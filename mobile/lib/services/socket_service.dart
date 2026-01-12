import 'package:flutter/foundation.dart';
import 'package:mobile/helpers/database_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  late IO.Socket _socket;

  final String _baseUrl = 'http://10.0.2.2:3000'; //ios: http://localhost:3000

  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void initConnection() {
    _loadLocalMessages();

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

    _socket.on('previous_messages', (data) async {
      if (data is List) {
        await DatabaseHelper.instance.insertBatch(
          List<Map<String, dynamic>>.from(data),
        );
        await _loadLocalMessages();
      }
    });

    _socket.on('message_deleted', (data) async {
      final id = data as int;

      await DatabaseHelper.instance.deleteMessage(id);

      _messages.removeWhere((msg) => msg['remote_id'] == id || msg['id'] == id);

      notifyListeners();
    });

    _socket.on('receive_message', (data) async {
      await DatabaseHelper.instance.insertMessage(
        Map<String, dynamic>.from(data),
      );
      _messages.add(Map<String, dynamic>.from(data));
      notifyListeners();
    });
  }

  void sendMessage(String text, String user) {
    _socket.emit('send_message', {'texto': text, 'usuario': user});
  }

  void deleteMessage(int id) {
    _socket.emit('delete_message', id);
  }

  Future<void> _loadLocalMessages() async {
    final localData = await DatabaseHelper.instance.getAllMessages();

    _messages = List<Map<String, dynamic>>.from(localData);

    print(' Carregadas ${_messages.length} mensagens do cache local.');
    notifyListeners();
  }

  void disconnect() {
    _socket.disconnect();
  }
}
