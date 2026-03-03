import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:todolist_app/components/app_dialog.dart';
import 'package:todolist_app/components/button/td_elevated_button.dart';
import 'package:todolist_app/models/task_model.dart';
import 'package:todolist_app/pages/main/widgets/card_task.dart';
import 'package:todolist_app/resources/app_color.dart';
import 'package:todolist_app/services/remote/body/delete_task_body.dart';
import 'package:todolist_app/services/remote/task_services.dart';
import 'package:todolist_app/utils/enum.dart';

class DeletedPage extends StatefulWidget {
  const DeletedPage({super.key});

  @override
  State<DeletedPage> createState() => _DeletedPageState();
}

class _DeletedPageState extends State<DeletedPage> {
  TaskServices taskServices = TaskServices();
  List<TaskModel> tasks = [];
  bool isLoading = false;

  List<String> get selectedIds {
    List<String> ids = [];
    for (var element in tasks) {
      if (element.isSelected == true) {
        ids = [...ids, element.id ?? ''];
      }
    }
    return ids;
  }

  @override
  void initState() {
    super.initState();
    _getDeletedTasks();
  }

  // Get List Deleted Task
  Future<void> _getDeletedTasks() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));

    final query = {'deleted': true};

    taskServices.getListTask(queryParams: query).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        // List<Map<String, dynamic>> maps = (data['body']['docs'] ?? [])
        //     .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>;
        final maps = (data['body']['docs'] ?? []).cast<Map<String, dynamic>>()
            as List<Map<String, dynamic>>;
        tasks = maps.map((e) => TaskModel.fromJson(e)).toList();
      } else {
        dev.log('object message ${data['message']}');
      }
    }).catchError((onError) {
      dev.log('$onError 😐');
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  // Delete Task
  void _deleteMultipleTask(DeleteTaskBody body) {
    taskServices.deleteMultipleTask(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        if (body.ids == null) {
          tasks.clear();
        } else {
          for (var id in body.ids!) {
            tasks.removeWhere((element) => (element.id ?? '') == id);
          }
        }
        setState(() {});
      } else {
        dev.log('object message ${data['message']}');
      }
    }).catchError((onError) {
      dev.log('$onError 😐');
    });
  }

  // Restore Task
  void _restoreMultipleTask(DeleteTaskBody body) {
    taskServices.restoreMultipleTask(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        if (body.ids == null) {
          tasks.clear();
        } else {
          for (var id in body.ids!) {
            tasks.removeWhere((element) => (element.id ?? '') == id);
          }
        }
        setState(() {});
      } else {
        dev.log('object message ${data['message']}');
      }
    }).catchError((onError) {
      dev.log('$onError 😐');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: tasks.isNotEmpty,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TdElevatedButton.smallOutline(
                onPressed: () => AppDialog.dialog(
                  context,
                  title: const Text('😍'),
                  content: 'Do you want to restore all task?',
                  action: () => _restoreMultipleTask(
                    DeleteTaskBody()..type = TaskType.RESTORE_ALL.name,
                  ),
                ),
                borderColor: AppColor.green,
                text: 'Restore All',
                textColor: AppColor.green,
                icon: const Icon(
                  Icons.restore,
                  size: 18.0,
                  color: AppColor.green,
                ),
              ),
              TdElevatedButton.smallOutline(
                onPressed: () {
                  for (var element in tasks) {
                    element.isConfirmDelete = false;
                  }
                  setState(() {});
                  AppDialog.dialog(
                    context,
                    title: const Text('😐'),
                    content: 'Do you want to permanently delete the task list?',
                    action: () => _deleteMultipleTask(
                      DeleteTaskBody()..type = TaskType.DELETE_ALL.name,
                    ),
                  );
                },
                text: 'Delete All',
                icon: const Icon(
                  Icons.delete,
                  size: 18.0,
                  color: AppColor.red,
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: selectedIds.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => AppDialog.dialog(
                      context,
                      title: const Text('😍'),
                      content: 'Restore the selected tasks?',
                      action: () => _restoreMultipleTask(
                        DeleteTaskBody()..ids = selectedIds,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Restore selected tasks',
                        style:
                            TextStyle(color: AppColor.primary, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => AppDialog.dialog(
                      context,
                      title: const Text('😐'),
                      content: 'Delete the selected tasks?',
                      action: () => _deleteMultipleTask(
                        DeleteTaskBody()..ids = selectedIds,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Delete selected tasks',
                        style:
                            TextStyle(color: AppColor.primary, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (tasks.isNotEmpty) const SizedBox(height: 8.0),
        const Divider(
          height: 1.2,
          thickness: 1.2,
          indent: 20.0,
          endIndent: 20.0,
          color: AppColor.primary,
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async {
              _getDeletedTasks();
            },
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  )
                : tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No deleted task',
                          style:
                              TextStyle(color: AppColor.brown, fontSize: 20.0),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                        itemCount: tasks.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          final task = tasks.reversed.toList()[index];
                          return CardTask(
                            task,
                            onRestore: () {
                              for (var element in tasks) {
                                element.isConfirmDelete = false;
                              }
                              setState(() {});
                              AppDialog.dialog(
                                context,
                                title: const Text('😍'),
                                content: 'Do you want to restore this task?',
                                action: () => _restoreMultipleTask(
                                  DeleteTaskBody()..ids = [task.id ?? ''],
                                ),
                              );
                            },
                            onDeleted: () {
                              for (var element in tasks) {
                                element.isConfirmDelete = false;
                              }
                              task.isConfirmDelete = true;
                              setState(() {});
                            },
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! < 0) return;
                              for (var element in tasks) {
                                element.isConfirmDelete = false;
                              }
                              task.isConfirmDelete = true;
                              setState(() {});
                            },
                            onConfirmYes: () => _deleteMultipleTask(
                              DeleteTaskBody()..ids = [task.id ?? ''],
                            ),
                            onConfirmNo: () {
                              task.isConfirmDelete = false;
                              setState(() {});
                            },
                            onSelected: () {
                              task.isSelected = !task.isSelected;
                              setState(() {});
                            },
                            confirmDeleteText: 'Permanently delete?',
                          );
                        }),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16.4),
                      ),
          ),
        ),
      ],
    );
  }
}
