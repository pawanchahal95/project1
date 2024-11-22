import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

// Custom Exceptions
class DatabaseAlreadyOpenException implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotFindUser implements Exception {}

class UnableToGetDocumentDirectory implements Exception {}

class CouldNotDeleteChat implements Exception {}

// Constants for database table and columns
const userTable = 'user';
const chatRoomTable = 'chatroom';

const emailColumn = 'email';
const messageColumn = 'message';
const senderIdColumn = 'SenderId';
const receiverIdColumn = 'ReceiverId';
const timestampColumn = 'timestamp';

const databaseName = 'chat_app.db';

// SQL Statements
const userTableSQL = '''
CREATE TABLE IF NOT EXISTS "user" (
  "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "email" TEXT NOT NULL UNIQUE
);''';

const chatRoomTableSQL = '''
CREATE TABLE IF NOT EXISTS "chatroom" (
  "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "message" TEXT NOT NULL,
  "SenderId" TEXT NOT NULL,
  "ReceiverId" TEXT NOT NULL,
  "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP
);''';

class ChatService {
  Database? _db;
  List<ChatRoom> _chats = [];
  List<DatabaseUsers> _users = [];

  late final StreamController<List<ChatRoom>> _chatStreamController;
  late final StreamController<List<DatabaseUsers>> _usersStreamController;

  late final StreamController<List<ChatRoom>> _newChatStreamController;
  late final StreamController<List<ChatRoom>> _newChatListStreamController;

  late final StreamController<List<DatabaseUsers>> _newUsersStreamController;

  static final ChatService _shared = ChatService._sharedInstance();

  ChatService._sharedInstance() {
    _chatStreamController =
        StreamController<List<ChatRoom>>.broadcast(onListen: () {
      _chatStreamController.add(_chats);
    });
    _newChatListStreamController =
    StreamController<List<ChatRoom>>.broadcast(onListen: () {
      _newChatListStreamController.add(_chats);
    });
    _newChatStreamController =
        StreamController<List<ChatRoom>>.broadcast(onListen: () {
      _newChatStreamController.add(_chats);
    });

    _usersStreamController =
        StreamController<List<DatabaseUsers>>.broadcast(onListen: () {
      _usersStreamController.add(_users);
    });
    _newUsersStreamController =
        StreamController<List<DatabaseUsers>>.broadcast(onListen: () {
      _newUsersStreamController.add(_users);
    });
  }

  factory ChatService() => _shared;

  // Streams
  Stream<List<ChatRoom>> get allChats => _chatStreamController.stream;

  Stream<List<DatabaseUsers>> get allUsers => _usersStreamController.stream;

  Stream<List<ChatRoom>> get allNewChats => _newChatStreamController.stream;
  Stream<List<ChatRoom>> get allNewChatsList => _newChatListStreamController.stream;

  Stream<List<DatabaseUsers>> get allNewUsers => _newUsersStreamController.stream;


  // Open the database
  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    try {
      final dbPath = await getApplicationDocumentsDirectory();
      final path = join(dbPath.path, databaseName);

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(userTableSQL);
          await db.execute(chatRoomTableSQL);
        },
      );

      // Cache data after opening the database
      await _cacheUsers();
      await _cacheChats();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) throw DatabaseIsNotOpen();

    await db.close();
    _db = null;

    await _chatStreamController.close();
    await _usersStreamController.close();
    await _newUsersStreamController.close();
    await _newChatStreamController.close();
    await _newChatListStreamController.close();
  }

  Future<void> _ensureDbIsOpen() async {
    if (_db == null) await open();
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) throw DatabaseIsNotOpen();
    return db;
  }

  // Cache data
  Future<void> _cacheUsers() async {
    final allUsers = await _getAllUsersFromDb();
    _users = allUsers.toList();
    _usersStreamController.add(_users);
    _newUsersStreamController.add(_users);
  }

  Future<void> _cacheChats() async {
    final allChats = await _getAllChatsFromDb();
    _chats = allChats.toList();
    _chatStreamController.add(_chats);
    _newChatStreamController.add(_chats);
    _newChatListStreamController.add(_chats);
  }

  // Users
  Future<DatabaseUsers?> getOrCreateUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    try {
      // Check if user exists
      final result = await db
          .query(userTable, where: '$emailColumn = ?', whereArgs: [email]);
      if (result.isEmpty) {
        // Create a new user
        final userId = await db.insert(userTable, {emailColumn: email});
        final newUser = DatabaseUsers(id: userId, email: email);

        // Cache and notify listeners
        _users.add(newUser);
        _usersStreamController.add(_users);
        _newUsersStreamController.add(_users);

        return newUser;
      }

      // Return existing user
      return DatabaseUsers.fromRow(result.first);
    } catch (e) {
      print('Error in getOrCreateUser: $e');
      return null;
    }
  }

  Future<List<DatabaseUsers>> _getAllUsersFromDb() async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(userTable);
    return result.map((row) => DatabaseUsers.fromRow(row)).toList();
  }

  // Chats
  Future<ChatRoom> createChat({
    required String message,
    required String senderId,
    required String receiverId,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final chatId = await db.insert(chatRoomTable, {
      messageColumn: message,
      senderIdColumn: senderId,
      receiverIdColumn: receiverId,
    });

    final newChat = ChatRoom(
      id: chatId,
      message: message,
      senderId: senderId,
      receiverId: receiverId,
      timestamp: DateTime.now().toIso8601String(),
    );

    // Cache and notify listeners
    _chats.add(newChat);
    _chatStreamController.add(_chats);
    _newChatStreamController.add(_chats);
    _newChatListStreamController.add(_chats);

    return newChat;
  }

  Future<void> deleteChat({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount =
        await db.delete(chatRoomTable, where: "id = ?", whereArgs: [id]);

    if (deletedCount != 1) throw CouldNotDeleteChat();

    // Update cache and notify listeners
    _chats.removeWhere((chat) => chat.id == id);
    _chatStreamController.add(_chats);
    _newChatStreamController.add(_chats);
    _newChatListStreamController.add(_chats);

  }

  Future<List<ChatRoom>> _getAllChatsFromDb() async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(chatRoomTable);
    return result.map((row) => ChatRoom.fromRow(row)).toList();
  }
}

// Models
class ChatRoom {
  final int id;
  final String message;
  final String senderId;
  final String receiverId;
  final String timestamp;

  ChatRoom({
    required this.id,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  ChatRoom.fromRow(Map<String, Object?> row)
      : id = row['id'] as int,
        message = row[messageColumn] as String,
        senderId = row[senderIdColumn] as String,
        receiverId = row[receiverIdColumn] as String,
        timestamp = row[timestampColumn] as String;
}

class DatabaseUsers {
  final int id;
  final String email;

  DatabaseUsers({required this.id, required this.email});

  DatabaseUsers.fromRow(Map<String, Object?> row)
      : id = row['id'] as int,
        email = row[emailColumn] as String;
}
