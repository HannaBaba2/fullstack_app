import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fullstack_app/app/widgets/offline_banner.dart';
import 'package:fullstack_app/app/widgets/error_retry.dart';
import 'package:fullstack_app/features/todos/presentation/providers/todos_provider.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodosProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: RefreshIndicator(
        onRefresh: () => context.read<TodosProvider>().load(),
        child: Column(
          children: [
            if (provider.isFromCache) const OfflineBanner(),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TodosProvider provider) {
    if (provider.isLoading && provider.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.todos.isEmpty) {
      return ErrorRetry(
        message: provider.errorMessage!,
        onRetry: () => context.read<TodosProvider>().load(),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: provider.todos.length,
      itemBuilder: (context, index) {
        final todo = provider.todos[index];
        return CheckboxListTile(
          value: todo.completed,
          onChanged: null,
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text('User ${todo.userId}'),
        );
      },
    );
  }
}
