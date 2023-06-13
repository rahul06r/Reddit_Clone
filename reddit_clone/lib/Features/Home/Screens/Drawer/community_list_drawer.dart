import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Core/common/sig_in_button.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:reddit_clone/themes/pallete.dart';
import 'package:routemaster/routemaster.dart';

import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';

class DrawerScreen extends ConsumerWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Routting
    void navigateRouteC(BuildContext context) {
      Routemaster.of(context).push('/create-community');
    }

    void navigateToCommunity(BuildContext context, Community community) {
      print(community.name);
      Routemaster.of(context).push('/r/${community.name}');
      // print(community.name);
    }

    final user = ref.watch(userProvider)!;

    final isNotUser = !user.isAuthenticated;

    return Drawer(
      child: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isNotUser) SignInButton(),
          SizedBox(height: 10),
          if (!isNotUser)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ListTile(
                title: const Text("Your Community"),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => navigateRouteC(
                  context,
                ),
              ),
            ),
          if (!isNotUser)
            ListTile(
              title: const Text("Create a community"),
              leading: const Icon(Icons.add),
              onTap: () => navigateRouteC(
                context,
              ),
            ),
          if (!isNotUser)
            ref.watch(userCommunityProvider).when(
                  data: (data) => Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final community = data[index];

                        if (data.isEmpty) {
                          return Center(
                            child: Text('No Post Found Yet'),
                          );
                        } else {
                          return ListTile(
                            onTap: () {
                              navigateToCommunity(context, community);
                            },
                            trailing: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.star_outline_outlined)),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                            title: Text("r/${community.name}"),
                          );
                        }
                      },
                    ),
                  ),
                  error: ((error, stackTrace) => ErrorText(
                        errorMessage: error.toString(),
                      )),
                  loading: () => const Loader(),
                ),
          if (!isNotUser)
            ListTile(
              title: const Text("Custom Feeds"),
              leading: const Icon(Icons.favorite_border),
              trailing: IconButton(
                  onPressed: () {}, icon: Icon(Icons.star_outline_outlined)),
              onTap: () => navigateRouteC(
                context,
              ),
            ),
          Divider(
            color: Pallete.whiteColor,
          ),
          // chnage icon for both
          if (!isNotUser)
            ListTile(
              title: const Text("Browse communities"),
              leading: const Icon(Icons.favorite_border),
              // trailing: IconButton(
              //     onPressed: () {}, icon: Icon(Icons.star_outline_outlined)),
              onTap: () => navigateRouteC(
                context,
              ),
            ),
          if (!isNotUser)
            ListTile(
              title: const Text("All"),
              leading: const Icon(Icons.favorite_border),
              // trailing: IconButton(
              //     onPressed: () {}, icon: Icon(Icons.star_outline_outlined)),
              onTap: () => navigateRouteC(
                context,
              ),
            ),
        ],
      )),
    );
  }
}
