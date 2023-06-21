import 'package:mylib/mylib.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:sqlite_test/database.dart';
import 'package:sqlite_test/model.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: Builder(builder: (context) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  child: const Text('sqflite3'),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HomePage())),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  static String title = 'Home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);
    final counter = useRef(0);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: todos.when(
          data: (data) => TodoListView(todos: data),
          error: (e, _) => Text(e.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ref.watch(todoProvider.notifier).create(no: counter.value++);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoListView extends ConsumerWidget {
  const TodoListView({super.key, required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (_, index) {
        return Card(
          color: index.color,
          child: ListTile(
            title: Text(todos[index].no.toString()),
            subtitle: Text(todos[index].createAt),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.watch(todoProvider.notifier).delete(todos[index].id);
              },
            ),
          ),
        );
      },
    );
  }
}
