import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';

class ModeratorEditScreen extends ConsumerStatefulWidget {
  final String name;
  const ModeratorEditScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ModeratorEditScreenState();
}

class _ModeratorEditScreenState extends ConsumerState<ModeratorEditScreen> {
  Set<String> uids = {};
  int ctr = 0;
  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void deleteUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  // save
  void saveMods() {
    ref.read(communityConProvider.notifier).addMods(
          widget.name,
          uids.toList(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(
              Icons.done,
            ),
          )
        ],
      ),
      body: ref.watch(getCommmuintyByNameProvider(widget.name)).when(
          data: (data) => ListView.builder(
                itemCount: data.members.length,
                itemBuilder: (BuildContext context, int index) {
                  final member = data.members[index];
                  return ref.watch(getUserDataProvider(member)).when(
                      data: (user) {
                        if (data.mods.contains(user.uid) && ctr == 0) {
                          // uids = data.mods.toSet();
                          uids.add(user.uid);
                        }
                        ctr++;
                        return CheckboxListTile(
                          title: Text(user.name),
                          value: uids.contains(user.uid),
                          onChanged: (value) {
                            if (value!) {
                              addUid(user.uid);
                            } else {
                              deleteUid(user.uid);
                            }
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(errorMessage: error.toString()),
                      loading: () => const Loader());
                },
              ),
          error: ((error, stackTrace) =>
              ErrorText(errorMessage: error.toString())),
          loading: () => const Loader()),
    );
  }
}
