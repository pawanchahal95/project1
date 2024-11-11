import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import'dart:async';

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class UserAlreadyExist implements Exception {}

class CouldNotDeleteUser implements Exception {}

class CouldNotFindUser implements Exception {}

class CouldNotDeleteNote implements Exception {}

class CouldNotFindNote implements Exception {}

class CouldNotUpdateNote implements Exception {}


class NoteService {
  Database? _db;
  List<DatabaseNotes> _notes = [];

  static final NoteService _shared = NoteService._sharedInstance();

  NoteService._sharedInstance() {
    _notesStreamController =
    StreamController<List<DatabaseNotes>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  factory NoteService() => _shared;

  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;


  Future<DatabaseNotes> updateHeading(
      {required DatabaseNotes note,
        required String heading,
      })
  async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(
      noteTable,
      {
        headingColumn: heading,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if(updateCount==0){
      throw CouldNotUpdateNote();
    }
    final updatedNote=await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await _ensureDbIsOpen();

    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNotes> updateNotes(
      {required DatabaseNotes note,
        required String text,
        })
  async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(
      noteTable,
      {
        textColumn: text,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if(updateCount==0){
      throw CouldNotUpdateNote();
    }
    final updatedNote=await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noterow) => DatabaseNotes.fromRow(noterow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final result = await db.query(
      noteTable,
      limit: 1,
      where: "id=?",
      whereArgs: [id],
    );
    if (result.isEmpty) {
      throw CouldNotFindNote();
    }
    //change made here
    else {
      final note = DatabaseNotes.fromRow(result.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletion;
  }

  Future<void> deleteNotes({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount =
    await db.delete(noteTable, where: "id=?", whereArgs: [id],);
    //change made here
    if (deletedCount ==0) {
      throw CouldNotDeleteNote();
    }
    else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNotes({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';

    final notesId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
    });
    final note = DatabaseNotes(
      id: notesId,
      userId: owner.id,
      text: text,
      heading:'sample'
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final result = await db
        .query(userTable, where: "email=?", whereArgs: [email.toLowerCase()]);
    if (result.isEmpty) {
      throw CouldNotFindUser();
    }
    else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: "email=?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExist();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final dbPath = await getApplicationDocumentsDirectory();
      final dbpath = join(dbPath.path, dbName);
      final db = await openDatabase(dbpath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person,ID=$id,email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final String heading;


  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
required this.heading
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
         heading=map[headingColumn]as String
  ;


  @override
  String toString() =>
      'Note, Id =$id,userId=$userId,text=$text,heading=$heading';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}


//these are the  variables needed
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const userIdColumn = 'user_id';
//change of up and down
const emailColumn = 'email';
const textColumn = 'text';

const headingColumn='heading';
//changes made in the table format
const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
	    "id"	INTEGER NOT NULL,
	    "email"	TEXT NOT NULL UNIQUE,
	    PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';
const createNoteTable = '''
     CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"heading"	TEXT NOT NULL DEFAULT 'sample',
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
