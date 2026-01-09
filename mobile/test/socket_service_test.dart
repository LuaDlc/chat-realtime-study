import 'dart:io' as IO;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/services/socket_service.dart';

// 1. Criamos um Mock da classe Socket original
class MockSocket extends Mock implements IO.Socket {}

void main() {
  late SocketService service;
  late MockSocket mockSocket;

  setUp(() {
    mockSocket = MockSocket();
    service = SocketService();
  });

  group('SocketService Tests', () {
    test('Deve inicializar desconectado', () {
      expect(service.isConnected, false);
    });

    test('Deve converter dados JSON corretamente ao receber mensagem', () {
      final rawData = {'userId': 'User1', 'content': 'Hello', 'id': 1};
    });
  });
}
