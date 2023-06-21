import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model.dart';

class DatabaseService {
  Database? _database;

  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  factory DatabaseService() => _instance;

  Future<Database> get database async {
    return _instance._database ?? await _initialize();
  }

  Future<String> get fullPath async {
    const name = 'todo.db';
    final path = await getDatabasesPath();

    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;

    _instance._database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );

    return _instance._database!;
  }

  Future<void> create(Database database, _) async =>
      await TodoAsyncNotifier().createTable(database);
}

class TodoAsyncNotifier extends AsyncNotifier<List<Todo>> {
  final tableName = 'todos';

  Future<void> createTable(Database database) async {
    await database.execute("""
      create table if not exists $tableName (
        "id" integer not null,
        "no" integer,
        "create_at" integer not null default(cast(strftime('%s', 'now') as integer)),
        "update_at" integer,
        primary key("id" autoincrement)
      );
""");
  }

  Future<void> create({required int no}) async {
    state = const AsyncValue.loading();

    final database = await DatabaseService().database;

    state = await AsyncValue.guard(() async {
      await database.rawInsert("""
      insert into $tableName (no, create_at) values (?,?)
""", [no, DateTime.now().millisecondsSinceEpoch]);

      return fetchAll();
    });
  }

  Future<List<Todo>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos = await database.rawQuery("""
    select * from $tableName order by coalesce(update_at, create_at)
""");

    return todos.map((todo) => Todo.fromSqfliteDatabase(todo)).toList();
  }

  Future<Todo> fetchById(int id) async {
    final database = await DatabaseService().database;

    final todo = await database.rawQuery("""
      select * from $tableName where id=?
""", [id]);

    return Todo.fromSqfliteDatabase(todo.first);
  }

  Future<void> updateTodo(int id, int? no) async {
    state = const AsyncValue.loading();

    final database = await DatabaseService().database;

    state = await AsyncValue.guard(() async {
      await database.update(
          tableName,
          {
            if (no != null) 'no': no,
            'update_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id =?',
          conflictAlgorithm: ConflictAlgorithm.rollback,
          whereArgs: [id]);

      return fetchAll();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();

    final database = await DatabaseService().database;

    state = await AsyncValue.guard(() async {
      await database.delete(tableName, where: 'id=?', whereArgs: [id]);

      return fetchAll();
    });
  }

  @override
  FutureOr<List<Todo>> build() {
    return fetchAll();
  }
}

final DatabaseService databaseService = DatabaseService();

final todoProvider =
    AsyncNotifierProvider<TodoAsyncNotifier, List<Todo>>(TodoAsyncNotifier.new);
