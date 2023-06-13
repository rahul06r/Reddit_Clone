import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    void navigateToCommunity(BuildContext context, String communityName) {
      Routemaster.of(context).push('/r/${communityName}');
    }

    return ref.watch(searchComuintyProvider(query)).when(
        data: (data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final community = data[index];
                return ListTile(
                  onTap: () => navigateToCommunity(context, community.name),
                  title: Text('r/${community.name}'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.avatar),
                  ),
                );
              },
            ),
        error: (error, stackTrace) => ErrorText(errorMessage: error.toString()),
        loading: () => const Loader());
  }
}
