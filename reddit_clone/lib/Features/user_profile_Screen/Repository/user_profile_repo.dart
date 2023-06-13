import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Models/user_model.dart';

import '../../../Core/Constant/firebase_constant.dart';
import '../../../Core/failure.dart';
import '../../../Core/providers/firebase_provider.dart';
import '../../../Core/type_def.dart';
import '../../../Models/postModel.dart';

final userprofileeditRepoProvider = Provider((ref) =>
    UserProfileRepository(firebaseFirestore: ref.watch(firestoreProvider)));

class UserProfileRepository {
  final FirebaseFirestore _firebaseFirestore;
  UserProfileRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  FutureVoid editProfileUser(UserModel user) async {
    try {
      return right(
        _users
            .doc(user.uid)
            .update(
              user.toMap(),
            )
            .then(
          (value) {
            // print("getted");
          },
        ),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'karma': user.karma,
      }).then((value) {
        // print("getted");
      }));
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // getting users collections getter
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _posts =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);
}
