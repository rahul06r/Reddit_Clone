import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/themes/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOutUser(WidgetRef ref) async {
    ref.read(authControllerProvider.notifier).logoutUser();
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void changeTheme(WidgetRef ref) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              // maxRadius: 30,
              // minRadius: 10,
              radius: 60,
              backgroundImage: NetworkImage(user.profilePic),
            ),
            const SizedBox(height: 10),
            Text(
              'u/${user.name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .18),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.drawerColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Pallete.statusGreen)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Online Status:',
                      style: TextStyle(
                        color: Pallete.statusGreen,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'On',
                      style: TextStyle(
                        color: Pallete.statusGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .09),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 5.0)
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    // stops: [0.0, , 1.0],
                    colors: [
                      Colors.red,
                      Colors.red,
                      Colors.redAccent,
                      Colors.orange,
                      Colors.orange,
                    ],
                  ),
                  color: Colors.deepPurple.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.transparent)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 25,
                        color: Pallete.whiteColor,
                      ),
                      // SizedBox(width: 5),
                      Text(
                        'Style Avatar',
                        style: TextStyle(
                            color: Pallete.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              // height: 50,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/karma Image.png',
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.karma}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Karma',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                    VerticalDivider(
                      color: Pallete.otherGrey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/days.png',
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2d',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Reddit age',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              color: Pallete.otherGrey,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector(
                      onTap: () => navigateToUserProfile(
                        context,
                        user.uid,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 23,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'My profile',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector(
                      onTap: () => navigateToUserProfile(
                        context,
                        user.uid,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 23,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Create a community',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector(
                      onTap: () => navigateToUserProfile(
                        context,
                        user.uid,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.save_alt,
                            size: 23,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Saved',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector(
                      onTap: () => navigateToUserProfile(
                        context,
                        user.uid,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 23,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'History',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text(
                "Log out",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              leading: Icon(
                Icons.logout,
                size: 30,
                color: Pallete.redColor,
              ),
              onTap: () => logOutUser(ref),
            ),
            Container(
              // height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Icon(
                          Icons.settings,
                          size: 23,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Settings',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.watch(themeNotifierProvider.notifier).toggleTheme();
                    },
                    icon: ref.watch(themeNotifierProvider.notifier).mode ==
                            ThemeMode.dark
                        ? Icon(
                            Icons.dark_mode_outlined,
                          )
                        : Icon(
                            Icons.light_mode,
                          ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 15),
                  //   child: Switch.adaptive(
                  //     inactiveTrackColor: Pallete.greencolor,
                  //     value: ref.watch(themeNotifierProvider.notifier).mode ==
                  //         ThemeMode.dark,
                  //     onChanged: (v) => ref
                  //         .watch(themeNotifierProvider.notifier)
                  //         .toggleTheme(),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
