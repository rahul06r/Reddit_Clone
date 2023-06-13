import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Post/Controller/post_controller.dart';
import 'package:reddit_clone/Features/Post/Repository/comment_repo.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../Core/enums/enum.dart';
import '../../../Core/utils.dart';
import '../../../Models/comments_model.dart';
import '../../../Models/postModel.dart';
import '../../user_profile_Screen/Controller/userProfile_controller.dart';

final getCommentPostProvider = StreamProvider.family((ref, String postId) {
  return ref.watch(commentConProvider.notifier).fetchCommentsPost(postId);
});

final commentConProvider =
    StateNotifierProvider<CommentController, bool>((ref) {
  final commentRepsoitory = ref.watch(commentRepoProvider);

  return CommentController(ref: ref, commentRepository: commentRepsoitory);
});

class CommentController extends StateNotifier<bool> {
  final CommentRepository _commentRepository;

  final Ref _ref;
  CommentController({
    required Ref ref,
    required CommentRepository commentRepository,
  })  : _ref = ref,
        _commentRepository = commentRepository,
        super(false);

  void addComment({
    required String text,
    required Post post,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;
    // final postrepo = _ref.read(postConProvider);
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      createdAt: DateTime.now(),
      postId: post.id,
      text: text,
      profilePic: user.profilePic,
      username: user.name,
      likesForComments: [],
      userPostedId: user.uid,
    );

    final res = await _commentRepository.addComment(comment);
    _ref
        .read(userProfileControlllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    // _ref.read(postConProvider)
    res.fold((l) => showsnackBars(context, l.message), (r) => null);
  }

  //
  void likesForComment(Comment comment) async {
    final user = _ref.read(userProvider)!;
    _commentRepository.likesFor(comment, user.uid);
  }

//
  void deleteComment(BuildContext context, Comment comment) async {
    final res = await _commentRepository.deleteComment(comment);
    res.fold((l) => showsnackBars(context, l.message), (r) {
      // Routemaster.of(context).pop();
      showsnackBars(context, 'Comment Deleted Successfully');
    });
  }

  Stream<List<Comment>> fetchCommentsPost(String postId) {
    return _commentRepository.getCommentsOfPost(postId);
  }
}
