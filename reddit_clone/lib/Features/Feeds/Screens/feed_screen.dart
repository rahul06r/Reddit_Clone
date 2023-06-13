import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Core/common/post_cards.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:reddit_clone/Features/Post/Controller/post_controller.dart';

import '../../Auth/Controllers/auth_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isNotUser = !user.isAuthenticated;

    if (!isNotUser) {
      return ref.watch(userCommunityProvider).when(
          data: (userCommunity) => ref
              .watch(userPostsProvider(userCommunity))
              .when(
                  data: (data) {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final posts = data[index];
                        return PostCard(post: posts);
                      },
                    );
                  },
                  error: (error, stackTace) =>
                      ErrorText(errorMessage: error.toString()),
                  loading: () => const Loader()),
          error: (error, stackTace) =>
              ErrorText(errorMessage: error.toString()),
          loading: () => const Loader());
    }
    // return Text('data');
    return ref.watch(userCommunityProvider).when(
        data: (userCommunity) => ref.watch(guestPostsProvider).when(
            data: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  final posts = data[index];
                  return PostCard(post: posts);
                },
              );
            },
            error: (error, stackTace) =>
                ErrorText(errorMessage: error.toString()),
            loading: () => const Loader()),
        error: (error, stackTace) => ErrorText(errorMessage: error.toString()),
        loading: () => const Loader());
  }
}
