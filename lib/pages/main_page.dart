import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:todolist_app/components/snack_bar/td_snack_bar.dart';
import 'package:todolist_app/components/snack_bar/top_snack_bar.dart';
import 'package:todolist_app/components/td_app_bar.dart';
import 'package:todolist_app/components/td_zoom_drawer.dart';
import 'package:todolist_app/constants/app_constant.dart';
import 'package:todolist_app/models/app_user_model.dart';
import 'package:todolist_app/pages/main/drawer_page.dart';
import 'package:todolist_app/pages/main/completed_page.dart';
import 'package:todolist_app/pages/main/deleted_page.dart';
import 'package:todolist_app/pages/main/home_page.dart';
import 'package:todolist_app/pages/main/uncompleted_page.dart';
import 'package:todolist_app/pages/profile/profile_page.dart';
import 'package:todolist_app/resources/app_color.dart';
import 'package:todolist_app/services/remote/account_services.dart';
import 'package:todolist_app/services/remote/code_error.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title, this.pageIndex});

  final String title;
  final int? pageIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final zoomDrawerController = ZoomDrawerController();
  late int selectedIndex;
  AccountServices accountServices = AccountServices();
  AppUserModel appUser = AppUserModel();

  List<Widget> pages = [
    const HomePage(),
    const CompletedPage(),
    const UncompletedPage(),
    const DeletedPage(),
  ];

  List<IconData> listIconData = [
    Icons.home,
    Icons.check_box,
    Icons.check_box_outline_blank,
    Icons.delete,
  ];

  List<String> listLabel = ['All', 'Completed', 'Uncompleted', 'Deleted'];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.pageIndex ?? 0;
    _getProfile(context);
  }

  void _getProfile(BuildContext context) {
    accountServices
        .getProfile()
        .then((response) {
          final data = jsonDecode(response.body);
          if (data['status_code'] == 200) {
            appUser = AppUserModel.fromJson(data['body']);
            setState(() {});
          } else {
            dev.log('object message ${data['message']}');
            if (!context.mounted) return;
            showTopSnackBar(
              context,
              TDSnackBar.error(message: (data['message'] as String?).toLang),
            );
          }
        })
        .catchError((onError) {
          if (!context.mounted) return;
          showTopSnackBar(
            context,
            const TDSnackBar.error(message: 'INTERNET_OR_SERVER'),
          );
        });
  }

  void toggleDrawer() {
    zoomDrawerController.toggle?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: TdAppBar(
          leftPressed: toggleDrawer,
          rightPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ProfilePage(appUser: appUser, pageIndex: selectedIndex),
            ),
          ),
          title: widget.title,
          avatar: '${AppConstant.endPointBaseImage}/${appUser.avatar ?? ''}',
          // avatar: AppConstant.baseImage(appUser.avatar ?? ''),
        ),
        body: TdZoomDrawer(
          controller: zoomDrawerController,
          menuScreen: DrawerPage(appUser: appUser, pageIndex: selectedIndex),
          screen: pages[selectedIndex],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return AnimatedContainer(
      height: 52.0,
      duration: const Duration(milliseconds: 2000),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(child: _navigationItem(index)),
        ),
        // children: [
        //   Expanded(
        //     child: _navigationItem(0),
        //   ),
        //   Expanded(
        //     child: _navigationItem(1),
        //   ),
        //   Expanded(
        //     child: _navigationItem(2),
        //   ),
        //   Expanded(
        //     child: _navigationItem(3),
        //   ),
        // ],
      ),
    );
  }

  Widget _navigationItem(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          selectedIndex = index;
          zoomDrawerController.close?.call();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withValues(alpha: 0.2),
              AppColor.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              listIconData[index],
              size: 22.0,
              color: index == selectedIndex
                  ? Colors.amber[800]
                  : AppColor.dark500,
            ),
            Text(
              listLabel[index],
              style: TextStyle(
                color: index == selectedIndex
                    ? Colors.amber[800]
                    : AppColor.dark500,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _navigationItem(int index) {
  //   return GestureDetector(
  //     behavior: HitTestBehavior.translucent,
  //     onTap: () {
  //       setState(() {
  //         selectedIndex = index;
  //         zoomDrawerController.close?.call();
  //       });
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             AppColor.primary.withValues(alpha: 0.2),
  //             AppColor.primary.withValues(alpha: 0.05),
  //           ],
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             // index == 0
  //             //     ? Icons.home
  //             //     : index == 1
  //             //         ? Icons.check_box
  //             //         : index == 2
  //             //             ? Icons.check_box_outline_blank
  //             //             : Icons.delete,
  //             () {
  //               if (index == 0) return Icons.home;
  //               if (index == 1) return Icons.check_box;
  //               if (index == 2) return Icons.check_box_outline_blank;
  //               return Icons.delete;
  //             }(),
  //             size: 22.0,
  //             color:
  //                 index == selectedIndex ? Colors.amber[800] : AppColor.dark500,
  //           ),
  //           Text(
  //             () {
  //               if (index == 0) return 'All';
  //               if (index == 1) return 'Completed';
  //               if (index == 2) return 'Uncompleted';
  //               return 'Deleted';
  //             }(),
  //             style: TextStyle(
  //               color: index == selectedIndex
  //                   ? Colors.amber[800]
  //                   : AppColor.dark500,
  //               fontSize: 12.0,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
