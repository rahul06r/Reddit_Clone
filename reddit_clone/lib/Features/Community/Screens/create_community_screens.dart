import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:reddit_clone/Responsive%20Materials/responsive_W.dart';
import 'package:reddit_clone/themes/pallete.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final TextEditingController _communityController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _communityController.dispose();
  }

  void createCommunity() {
    ref
        .read(communityConProvider.notifier)
        .createCommunity(_communityController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityConProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Create a Community",
        ),
      ),
      body: isLoading
          ? const Loader()
          : ResponsiveW(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Community name",
                        style: TextStyle(
                          color: Pallete.whiteColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _communityController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'r/Community_name',
                        filled: true,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLength: 21,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: createCommunity,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Pallete.blueColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Create community",
                        style: TextStyle(
                            color: Pallete.whiteColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
