import 'package:flutter/material.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/notificationController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/feature/PTDisplay/ptlistpage.dart';
import 'package:ontrain/feature/book/home/homeTab.dart';
import 'package:ontrain/feature/book/sessiondisplay/sessionpage.dart';
import 'package:ontrain/feature/profile/profilepage.dart';
import 'package:ontrain/feature/specialties/specialtiesScreen.dart';
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
      _buildHomeTab(),
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

  Widget _buildHomeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(23.0),
          child: Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      // IconButton.filledTonal(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.notifications_none_sharp),
                      // ),
                      // IconButton.filledTonal(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.settings),
                      // ),
                      IconButton.filledTonal(
                        onPressed: () {},
                        icon: Icon(Icons.search),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    height: 40,
                    width: 170,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Hi, WelcomeBack",
                              style: TextStyle(color: AppColors.aquaTeal),
                            ),
                            Consumer<AuthController>(
                              builder: (context, authController, child) {
                                return Text(
                                  authController.user?.name ?? 'Loading...',
                                );
                              },
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(isMainScreen: false),
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(
                              "assets/PXL_20251014_011048644~2.jpg",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Category",
                    style: TextStyle(
                      color: AppColors.aquaTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CateBtn(
                    title: "Favorite",
                    ico: Icons.favorite,
                    onCall: () {},
                  ),
                  CateBtn(
                    title: "PT",
                    ico: Icons.person,
                    onCall: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PTListpage()),
                      );
                    },
                  ),
                  CateBtn(title: "GYM", ico: Icons.map, onCall: () {}),
                  CateBtn(
                    title: "Specialties",
                    ico: Icons.school,
                    onCall: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecialtiesScreen(),
                        ),
                      );
                    },
                  ),
                  CateBtn(
                    title: "Records",
                    ico: Icons.receipt_long,
                    onCall: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: TableCalendarEx()),
      ],
    );
  }
}

class CateBtn extends StatelessWidget {
  CateBtn({
    super.key,
    required this.onCall,
    required this.title,
    required this.ico,
  });
  VoidCallback onCall;
  String title;
  IconData ico;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {onCall()},
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Icon(ico, color: AppColors.aquaTeal),
          ),
          Text(title, style: TextStyle(color: AppColors.aquaTeal)),
        ],
      ),
    );
  }
}
