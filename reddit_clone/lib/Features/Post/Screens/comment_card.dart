// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Post/Controller/comment_controller.dart';
import 'package:reddit_clone/Responsive%20Materials/responsive_W.dart';
import 'package:reddit_clone/themes/pallete.dart';

import '../../../Models/comments_model.dart';

class Commentcard extends ConsumerWidget {
  final Comment comment;
  const Commentcard({
    super.key,
    required this.comment,
  });

  void likesAdd(WidgetRef ref) {
    ref.read(commentConProvider.notifier).likesForComment(comment);
  }

  void deleteComment(BuildContext context, WidgetRef ref) {
    ref.read(commentConProvider.notifier).deleteComment(context, comment);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider)!;

    return ResponsiveW(
      child: GestureDetector(
        onLongPress: () {
          print("Long Pressed ${comment.id}");
          if (user.uid == comment.userPostedId)
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Comment'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "No",
                          style: TextStyle(color: Pallete.whiteColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          deleteComment(context, ref);
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Pallete.whiteColor),
                        ),
                      )
                    ],
                  );
                });
          //
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      comment.profilePic,
                    ),
                    radius: 18,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'u/${comment.username}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${comment.text}',
                          // maxLines: 2,
                        ),
                      ],
                    ),
                  )),
                  //
                  if (user.uid != comment.userPostedId)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            print('Pressed');
                            likesAdd(ref);
                          },
                          icon: Icon(
                            comment.likesForComments.contains(user.uid)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: comment.likesForComments.contains(user.uid)
                                ? Pallete.redColor
                                : Pallete.whiteColor,
                          ),
                        ),
                        Text(
                          comment.likesForComments.length.toString(),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.reply,
                    ),
                  ),
                  const Text('Reply')
                ],
              ),
              Divider(
                height: 5,
                thickness: 2,
                color: Pallete.greyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
