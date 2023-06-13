// ignore_for_file: public_member_api_docs,P
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/post_cards.dart';
import 'package:reddit_clone/Features/Post/Controller/comment_controller.dart';
import 'package:reddit_clone/Features/Post/Controller/post_controller.dart';
import 'package:reddit_clone/Features/Post/Screens/comment_card.dart';
import 'package:reddit_clone/Responsive%20Materials/responsive_W.dart';

import '../../../Core/common/errorText.dart';
import '../../../Core/common/loader.dart';
import '../../../Models/postModel.dart';
import '../../Auth/Controllers/auth_controller.dart';

class CommentPost extends ConsumerStatefulWidget {
  final String postID;
  const CommentPost({
    super.key,
    required this.postID,
    String? postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentPostState();
}

class _CommentPostState extends ConsumerState<CommentPost> {
  final commentController = TextEditingController();

  void addComment(Post post) {
    ref.read(commentConProvider.notifier).addComment(
        text: commentController.text.trim(), post: post, context: context);
    setState(() {
      commentController.text = '';
    });
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isNotUser = !user.isAuthenticated;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postID)).when(
            data: (data) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    PostCard(post: data),
                    const SizedBox(height: 10),
                    if (!isNotUser)
                      ResponsiveW(
                        child: TextField(
                          // u can adjust accordingly
                          maxLength: 150,
                          onSubmitted: (val) => addComment(data),
                          decoration: const InputDecoration(
                            hintText: 'What\'s your thought',
                            filled: true,
                            border: InputBorder.none,
                          ),
                          controller: commentController,
                        ),
                      ),
                    ref.watch(getCommentPostProvider(widget.postID)).when(
                          data: (data) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = data[index];
                                return Commentcard(comment: comment);
                              },
                            );
                          },
                          error: (e, stacktrace) =>
                              ErrorText(errorMessage: e.toString()),
                          loading: () => const Loader(),
                        ),
                  ],
                ),
              );
            },
            error: (e, stacktrace) => ErrorText(errorMessage: e.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
