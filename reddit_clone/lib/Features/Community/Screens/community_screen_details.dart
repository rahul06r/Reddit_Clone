import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../Core/common/post_cards.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Routing
    void goToModToolsPage(BuildContext context) {
      Routemaster.of(context).push('/mod-tools/$name');
    }

    //
    void joinCommunity(
        WidgetRef ref, BuildContext context, Community community) {
      ref.read(communityConProvider.notifier).joinCommuinty(community, context);
    }

    final user = ref.watch(userProvider)!;
    final isNotUser = !user.isAuthenticated;
    return Scaffold(
      body: ref.watch(getCommmuintyByNameProvider(name)).when(
            data: (data) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            data.banner,
                            fit: BoxFit.cover,
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
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(data.avatar),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'r/${data.name}',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!isNotUser)
                                data.mods.contains(user.uid)
                                    ? OutlinedButton(
                                        onPressed: () =>
                                            goToModToolsPage(context),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        child: const Text(
                                          "Mods tools",
                                        ),
                                      )
                                    : OutlinedButton(
                                        onPressed: () =>
                                            joinCommunity(ref, context, data),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        child: Text(
                                          data.members.contains(user.uid)
                                              ? "Joined"
                                              : "Join",
                                        ),
                                      ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 6),
                            child: Text('${data.members.length} members'),
                          ),
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: ref.watch(getCommunityPostsProvider(name)).when(
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
