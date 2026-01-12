import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER';

    await db.execute('''
      CREATE TABLE messages (
        id $idType,           
        content $textType,
        userId $textType,
        remote_id $intType,
        createdAt $textType   
      )
    ''');
  }

  Map<String, dynamic> _mapToLocal(Map<String, dynamic> row) {
    final newRow = Map<String, dynamic>.from(row);
    if (newRow.containsKey('id')) {
      newRow['remote_id'] = newRow['id'];
      newRow.remove('id');
    }
    return newRow;
  }

  Future<int> insertMessage(Map<String, dynamic> row) async {
    final db = await instance.database;

    // ConflictAlgorithm.replace: Se chegar uma mensagem com mesmo ID, substitui (atualiza)
    return await db.insert(
      'messages',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllMessages() async {
    final db = await instance.database;
    //  'orderBy' garante que apareçam na ordem correta
    return await db.query('messages', orderBy: 'id ASC');
  }

  Future<void> insertBatch(List<Map<String, dynamic>> messages) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var msg in messages) {
      batch.insert(
        'messages',
        msg,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> deleteMessage(int remoteId) async {
    final db = await instance.database;

    return await db.delete(
      'messages',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
    );
  }
}
