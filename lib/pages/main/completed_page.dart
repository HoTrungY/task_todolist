import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist_app/components/app_dialog.dart';
import 'package:todolist_app/components/td_search_box.dart';
import 'package:todolist_app/models/task_model.dart';
import 'package:todolist_app/pages/main/widgets/card_task.dart';
import 'package:todolist_app/resources/app_color.dart';
import 'package:todolist_app/services/remote/body/task_body.dart';
import 'package:todolist_app/services/remote/task_services.dart';
import 'package:todolist_app/utils/enum.dart';

class CompletedPage extends StatefulWidget {
  const CompletedPage({super.key});

  @override
  State<CompletedPage> createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  final searchController = TextEditingController();
  final editController = TextEditingController();
  final editFocus = FocusNode();
  bool isLoading = false;

  ///===========================///
  TaskServices taskServices = TaskServices();
  List<TaskModel> tasks = [];
  List<TaskModel> tasksSearch = [];

  @override
  void initState() {
    super.initState();
    _getCompletedTasks();
  }

  // Get List Task Completed
  Future<void> _getCompletedTasks() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));

    final query = {
      'status': StatusType.DONE.name,
      'deleted': false,
    };

    taskServices.getListTask(queryParams: query).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        // final maps = (data['body']['docs'] ?? [])
        //     .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>;
        List<Map<String, dynamic>> maps = (data['body']['docs'] ?? [])
            .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>;
        tasks = maps.map((e) => TaskModel.fromJson(e)).toList();
        // tasksSearch = [...tasks];
        _search(searchController.text);
      } else {
        dev.log('object message ${data['message']}');
      }
    }).catchError((onError) {
      dev.log('$onError 😐');
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void _updateTask(TaskModel task) {
    TaskBody body = TaskBody()
      ..id = task.id
      ..name = task.name
      ..description = task.description
      ..status = task.status;

    taskServices.updateTask(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        tasks.singleWhere((element) => element.id == body.id)
          ..name = body.name
          ..description = body.description
          ..status = body.status;
        tasksSearch.singleWhere((element) => element.id == body.id)
          ..name = body.name
          ..description = body.description
          ..status = body.status;

        if (body.status == StatusType.PROCESSING.name) {
          tasks.removeWhere((element) => element.id == body.id);
          tasksSearch.removeWhere((element) => element.id == body.id);
        }

        setState(() {});
      } else {
        dev.log('object message ${data['message']}');
      }
    }).catchError((onError) {
      dev.log('object $onError');
    });
  }

  void _deleteTask(String id) {
    taskServices.deleteTask(id).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        tasks.removeWhere((element) => (element.id ?? '') == id);
        tasksSearch.removeWhere((element) => (element.id ?? '') == id);
        setState(() {});
      } else {
        dev.log('object message ${data['message']}');
      }
    }).catchError((onError) {
      dev.log('object $onError');
    });
  }

  void _search(String value) {
    value = value.toLowerCase();
    setState(() {
      tasksSearch = tasks
          .where(
              (element) => (element.name ?? '').toLowerCase().contains(value))
          .toList();
    });
  }

  // void _onEdit(TaskModel task) {
  //   setState(() {
  //     // close all edit task before open new edit task
  //     for (var element in tasks) {
  //       element.isEditing = false;
  //     }
  //     task.isEditing = true;
  //     editController.text = task.name ?? '';
  //     editFocus.requestFocus();
  //   });
  // }

  void _onDeleted(TaskModel task) {
    AppDialog.dialog(
      context,
      title: const Text('😐'),
      content: 'Do you want to delete this task?',
      action: () => _deleteTask(task.id ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TdSearchBox(
            controller: searchController,
            onChanged: _search,
          ),
        ),
        const SizedBox(height: 16.0),
        const Divider(
          height: 2.0,
          indent: 20.0,
          endIndent: 20.0,
          color: AppColor.primary,
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async {
              _getCompletedTasks();
            },
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.primary))
                : tasksSearch.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? 'No completed task'
                              : 'There is no result',
                          style: const TextStyle(
                              color: AppColor.brown, fontSize: 20.0),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SlidableAutoCloseBehavior(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 16.0),
                            itemCount: tasksSearch.length,
                            reverse: true,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final task = tasksSearch[index];
                              return Slidable(
                                key: ValueKey(task.id),
                                startActionPane: _actionPane(task),
                                // endActionPane: _actionPane(task),
                                child: CardTask(
                                  task,
                                  editController: editController,
                                  editFocus: editFocus,
                                  onTap: () => AppDialog.dialog(
                                    context,
                                    title: const Text('😍'),
                                    content: 'The task status will be changed?',
                                    action: () {
                                      task.status = StatusType.PROCESSING.name;
                                      _updateTask(task);
                                    },
                                  ),
                                  // onEdit: () => _onEdit(task),
                                  // onLongPress: () => _onEdit(task),
                                  // onSave: () {
                                  //   task.name = editController.text.trim();
                                  //   _updateTask(task);
                                  //   setState(() {
                                  //     task.isEditing = false;
                                  //   });
                                  // },
                                  // onCancel: () {
                                  //   setState(() {
                                  //     task.isEditing = false;
                                  //   });
                                  // },
                                  onDeleted: () => _onDeleted(task),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16.4),
                          ),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  ActionPane _actionPane(TaskModel task) {
    return ActionPane(
      motion: const DrawerMotion(),
      // motion: const StretchMotion(),
      children: [
        // SlidableAction(
        //   onPressed: (_) => _onEdit(task),
        //   backgroundColor: const Color(0xFF21B7CA),
        //   foregroundColor: Colors.white,
        //   icon: Icons.edit,
        // ),
        SlidableAction(
          onPressed: (_) => _deleteTask(task.id ?? ''),
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
        ),
      ],
    );
  }
}
