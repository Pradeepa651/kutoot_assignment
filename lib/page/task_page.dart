import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc/task_bloc.dart';
import '../model/task.dart' show Task;
import '../repo/task_repo.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: Dialog(
            insetPadding: EdgeInsets.all(4),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AddTask(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TaskBloc(taskRepo: context.read<TaskRepository>())..add(TaskLoaded()),
      child: BlocListener<TaskBloc, TaskState>(
        listenWhen: (previous, current) =>
            previous.showSyncError != current.showSyncError,
        listener: (context, state) {
          if (state.showSyncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to sync tasks')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Task Page')),
          body: TaskListView(),
          floatingActionButton: BlocSelector<TaskBloc, TaskState, Status>(
            selector: (state) {
              return state.status;
            },
            builder: (context, status) {
              final isLoading =
                  status == Status.loading || status == Status.refresh;
              return FloatingActionButton(
                onPressed: isLoading
                    ? null
                    : () {
                        _showAddDialog(context);
                      },
                child: isLoading
                    ? const Center(
                        child: RepaintBoundary(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const Icon(Icons.add),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});
  void _showEditDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: Dialog(
            insetPadding: EdgeInsets.all(4),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: EditTask(task: task),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            return switch (state.status) {
              Status.initial ||
              Status.loading ||
              Status.refresh => SliverFillRemaining(
                child: const Center(
                  child: RepaintBoundary(child: CircularProgressIndicator()),
                ),
              ),
              Status.success || Status.updated => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = state.tasks[index];
                  final isSynced = !state.unSyncedTasks.contains(task);
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    onTap: () {
                      _showEditDialog(context, task);
                    },
                    trailing: isSynced
                        ? const Icon(Icons.check, color: Colors.blue, size: 12)
                        : const Icon(
                            Icons.sync,
                            color: Colors.orange,
                            size: 12,
                          ),
                  );
                }, childCount: state.tasks.length),
              ),

              Status.error => SliverFillRemaining(
                child: Center(
                  child: Text(state.errorMessage ?? 'An error occurred'),
                ),
              ),
              _ => const SliverToBoxAdapter(),
            };
          },
        ),
      ],
    );
  }
}

class EditTask extends StatefulWidget {
  const EditTask({super.key, required this.task});
  final Task task;

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _titleController.text = widget.task.title;
    _descriptionController.text = widget.task.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
            controller: _titleController,

            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: _descriptionController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    final title = _titleController.text.trim();
                    final description = _descriptionController.text.trim();

                    context.read<TaskBloc>().add(
                      TaskEdited(
                        title: title,
                        description: description,
                        id: widget.task.id,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
            controller: _titleController,

            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: _descriptionController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    final title = _titleController.text.trim();
                    final description = _descriptionController.text.trim();

                    context.read<TaskBloc>().add(
                      TaskAdded(title: title, description: description),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
