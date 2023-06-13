import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/Constant/firebase_constant.dart';
import 'package:reddit_clone/Core/failure.dart';
import 'package:reddit_clone/Core/providers/firebase_provider.dart';
import 'package:reddit_clone/Models/community_model.dart';

import '../../../Core/type_def.dart';
import '../../../Models/postModel.dart';

final communityRepoProvider = Provider((ref) =>
    CommunityRespository(firebaseFirestore: ref.watch(firestoreProvider)));

class CommunityRespository {
  final FirebaseFirestore _firebaseFirestore;
  CommunityRespository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

//

// check here he used FutureVoid
  FutureVoid createCommunity(Community community) async {
    try {
      //

      var communitydocs = await _collectionsref.doc(community.name).get();

      //
      print(communitydocs);
      if (communitydocs.exists) {
        throw 'Commnuity with the same name exists';
      }
      return right(_collectionsref.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // get user specific community

  // Stream<List<Community>> resetCommunity() {
  //   return Stream.empty();
  // }

  Stream<List<Community>> getUserCommunity(String uid) {
    return _collectionsref
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

//
  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(
        _collectionsref.doc(communityName).update(
          {
            'members': FieldValue.arrayUnion([userId]),
          },
        ),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //
  //
  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(
        _collectionsref.doc(communityName).update(
          {
            'members': FieldValue.arrayRemove([userId]),
          },
        ),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_collectionsref
          .doc(community.name)
          .update(
            community.toMap(),
          )
          .then((value) {
        // print("getted");
      }));
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

//
//
  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_collectionsref.doc(communityName).update({
        'mods': uids,
      }).then((value) {
        // print("getted");
      }));
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

//

  Stream<List<Community>> searchCommunity(String query) {
    return _collectionsref
        .where('name',
            isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
            isLessThan: query.isEmpty
                ? null
                : query.substring(0, query.length - 1) +
                    String.fromCharCode(query.codeUnitAt(query.length - 1) + 1))
        .snapshots()
        .map((event) {
      List<Community> community = [];
      for (var element in event.docs) {
        community
            .add(Community.fromMap(element.data() as Map<String, dynamic>));
      }
      return community;
    });
  }

  //

  Stream<List<Post>> getCommunityPost(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
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

  //

  CollectionReference get _posts =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);
  // Getting coumnity by name
  Stream<Community> getCommunityByName(String name) {
    return _collectionsref.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

// getting community collections getter
  CollectionReference get _collectionsref =>
      _firebaseFirestore.collection(FirebaseConstants.communitiesCollection);
}
