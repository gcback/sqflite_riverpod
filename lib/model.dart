import 'package:mylib/mylib.dart';

@immutable
class Todo {
  final int id;

  final int no;
  final String createAt;
  final String? updateAt;

  const Todo({
    required this.id,
    required this.no,
    required this.createAt,
    this.updateAt,
  });

  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) => Todo(
        id: map['id']?.toInt() ?? 0,
        no: map['no']?.toInt() ?? 0,
        createAt: DateTime.fromMillisecondsSinceEpoch(map['create_at'])
            .toIso8601String(),
        updateAt: map['update_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['update_at'])
                .toIso8601String(),
      );
}
