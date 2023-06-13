// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/Constant/constants.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Home/Screens/Drawer/community_list_drawer.dart';
import 'package:reddit_clone/themes/pallete.dart';
import 'package:routemaster/routemaster.dart';

import 'Drawer/profile_drawer.dart';
import 'Search_Delegate/search_community_delegate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  //
  void opendCommunityDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  //
  void openProfileEndDrwaer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  //
  int _page = 0;
  void onChnagedPage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    final isNotUser = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      // backgroundColor: Colors.red,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
          if (kIsWeb)
            IconButton(
                onPressed: () {
                  Routemaster.of(context).push('/add_post/');
                },
                icon: const Icon(
                  Icons.add,
                )),
          // const SizedBox(height: 10),
          Builder(builder: (context) {
            return IconButton(
              // iconSize:,
              onPressed: () {
                openProfileEndDrwaer(context);
              },
              icon: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.profilePic,
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Icon(
                      Icons.circle,
                      size: 15,
                      color: Pallete.statusGreen,
                    ),
                  )
                ],
              ),
            );
          }),
        ],
        title: Text(
          _page.toString(),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => opendCommunityDrawer(context),
            icon: const Icon(Icons.menu),
          );
        }),
      ),
      body: Constants.feedWidgets[_page],
      drawer: const DrawerScreen(),
      endDrawer: isNotUser ? null : const ProfileDrawer(),
      bottomNavigationBar: isNotUser || kIsWeb
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.backgroundColor,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.explore), label: 'Discover'),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble), label: 'Chat'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.notifications), label: 'Inbox'),
              ],
              onTap: onChnagedPage,
              currentIndex: _page,
            ),
    );
  }
}
