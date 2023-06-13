import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/Constant/firebase_constant.dart';

import '../../../Core/failure.dart';
import '../../../Core/providers/firebase_provider.dart';
import '../../../Core/type_def.dart';
import '../../../Models/comments_model.dart';
import '../../../Models/community_model.dart';
import '../../../Models/postModel.dart';

final postRepoProvider = Provider(
    (ref) => PostRepository(firebaseFirestore: ref.watch(firestoreProvider)));

class PostRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

//
  FutureVoid addPost(Post post) async {
    try {
      return right(
        _post.doc(post.id).set(post.toMap()),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //
  Stream<List<Post>> festchUserCommuintyPosts(List<Community> communities) {
    return _post
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  //

  // fetch Guest post limit ur post for guest
  Stream<List<Post>> festchGuestPosts() {
    return _post
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  //

  // delete
  FutureVoid deletePost(Post post) async {
    try {
      return right(await _post.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //
  // Voiting part
  void upVote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.upvotes.contains(userId)) {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downVote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.downvotes.contains(userId)) {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<Post> getPostById(String postId) {
    return _post
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  //
  // Awarding karma to user

  FutureVoid awardPost(Post post, String award, String senderId) async {
    try {
      _post.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award]),
      });
      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award]),
      });
      return right(_users.doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _post =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firebaseFirestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);
}
