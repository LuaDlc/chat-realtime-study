import 'package:flutter/material.dart';
import 'package:mobile/screens/chat_screen.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SocketService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Real-time',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: ChatScreen(),
    );
  }
}
