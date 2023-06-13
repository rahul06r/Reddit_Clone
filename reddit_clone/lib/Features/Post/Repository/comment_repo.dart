import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/providers/firebase_provider.dart';

import '../../../Core/Constant/firebase_constant.dart';
import '../../../Core/failure.dart';
import '../../../Core/type_def.dart';
import '../../../Models/comments_model.dart';

final commentRepoProvider = Provider((ref) =>
    CommentRepository(firebaseFirestore: ref.watch(firestoreProvider)));

class CommentRepository {
  final FirebaseFirestore _firebaseFirestore;
  CommentRepository({
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;
  //
  // comment
  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(
            comment.toMap(),
          );
      return right(
        _post.doc(comment.id).update({
          'commentCount': FieldValue.increment(1),
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  //

  void likesFor(Comment comment, String userId) async {
    if (comment.likesForComments.contains(userId)) {
      _comments.doc(comment.id).update({
        'likesForComments': FieldValue.arrayRemove([userId]),
      });
    } else {
      _comments.doc(comment.id).update({
        'likesForComments': FieldValue.arrayUnion([userId]),
      });
    }
  }

  //
  FutureVoid deleteComment(Comment comment) async {
    try {
      return right(await _comments.doc(comment.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //

  CollectionReference get _post =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _comments =>
      _firebaseFirestore.collection(FirebaseConstants.commentsCollection);
}
