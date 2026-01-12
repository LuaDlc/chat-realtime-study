import 'package:flutter/material.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = .new();
  final String _myUser = 'LuanaMobile';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocketService>(context, listen: false).initConnection();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    //  Provider.of<SocketService>(context, listen: false).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Flutter'),
        backgroundColor: socketService.isConnected ? Colors.green : Colors.red,
        actions: [
          Icon(
            socketService.isConnected ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildMessageList(socketService),
          _buildInputArea(socketService),
        ],
      ),
    );
  }

  Widget _buildMessageList(SocketService service) {
    return Expanded(
      child: ListView.builder(
        itemCount: service.messages.length,
        itemBuilder: (context, index) {
          final msg = service.messages[index];
          final isMe = msg['userId'] == _myUser;

          return GestureDetector(
            onLongPress: () {
              if (isMe) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Apagar mensagem?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          final id = msg['remote_id'] ?? msg['id'];
                          service.deleteMessage(id);

                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          'Apagar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue[100] : Colors.grey[300],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg['userId'] ?? 'Anon',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.blue[900] : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      msg['content'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(SocketService service) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Digite uma mensagem...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(service),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _sendMessage(service),
          ),
        ],
      ),
    );
  }

  void _sendMessage(SocketService service) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      service.sendMessage(text, _myUser);
      _textController.clear();
    }
  }
}
