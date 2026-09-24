import 'package:flutter/material.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/notificationController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/feature/PTDisplay/ptlistpage.dart';
import 'package:ontrain/feature/book/home/homeTab.dart';
import 'package:ontrain/feature/book/sessiondisplay/sessionpage.dart';
import 'package:ontrain/feature/profile/profilepage.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().getCurrentUserData();
      context.read<NotificationController>().fetchNotifications();
      context.read<NotificationController>().fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeTab(),
      const PTListpage(),
      const SessionPage(),
      const ProfilePage(isMainScreen: true),
    ];

    return Scaffold(
      bottomNavigationBar: Consumer<NotificationController>(
        builder: (context, notificationController, child) {
          return NavigationBar(
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: AppColors.aquaTeal,
            destinations: [
              const NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              const NavigationDestination(
                selectedIcon: Icon(Icons.person_search),
                icon: Icon(Icons.person_search_outlined),
                label: 'Find PT',
              ),
              NavigationDestination(
                selectedIcon: Badge(
                  isLabelVisible: false, // we handle visibility manually
                  child: Icon(Icons.calendar_month),
                ),
                icon: Badge(
                  label: Text(
                    notificationController.unreadCount > 9
                        ? '9+'
                        : notificationController.unreadCount.toString(),
                  ),
                  isLabelVisible: notificationController.unreadCount > 0,
                  child: const Icon(Icons.calendar_month_outlined),
                ),
                label: 'Sessions',
              ),
              const NavigationDestination(
                selectedIcon: Icon(Icons.person),
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
      body: IndexedStack(index: currentPageIndex, children: pages),
    );
  }
}
