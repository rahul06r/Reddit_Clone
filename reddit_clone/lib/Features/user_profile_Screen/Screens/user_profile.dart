import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/user_profile_Screen/Controller/userProfile_controller.dart';

import 'package:routemaster/routemaster.dart';

import '../../../Core/common/errorText.dart';
import '../../../Core/common/loader.dart';
import '../../../Core/common/post_cards.dart';
import '../../Auth/Controllers/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({
    super.key,
    required this.uid,
  });

  void navigateToeditProfileScreen(BuildContext context) {
    Routemaster.of(context).push('/edit_profile/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final user = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (data) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.black,
                    actions: [
                      IconButton(
                          onPressed: () {
                            navigateToeditProfileScreen(context);
                          },
                          icon: Icon(
                            Icons.edit,
                          )),
                      IconButton(
                          onPressed: () {
                            // navigateToeditProfileScreen(context);
                          },
                          icon: Icon(
                            Icons.share,
                          )),
                    ],
                    title: Text(data.name),
                    expandedHeight: 250,
                    floating: true,
                    // snap: true,
                    pinned: true,
                    flexibleSpace: Stack(
                      children: [
                        //

                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(20).copyWith(
                            bottom: 70,
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              data.profilePic,
                            ),
                            radius: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // const SizedBox(height: 10),

                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'u/${data.name}',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Row(
                              children: [
                                Text(
                                  "0 followers",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.chevron_right_sharp,
                                    ))
                              ],
                            ),
                          ),
                          const SizedBox(),
                          const Divider(thickness: 2),
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: ref.watch(getUserPostsProvider(uid)).when(
                    data: (data) {
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = data[index];
                          return PostCard(post: post);
                        },
                      );
                    },
                    error: (error, stackTrace) {
                      return ErrorText(errorMessage: error.toString());
                    },
                    loading: () => const Loader(),
                  ),
            ),
            error: (error, stackTrace) =>
                ErrorText(errorMessage: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
