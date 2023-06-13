import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/Constant/constants.dart';
import 'package:reddit_clone/Core/failure.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Community/Repsoitory/community_repository.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../Core/providers/stroage_repsoitory.dart';
import '../../../Core/utils.dart';
import '../../../Models/postModel.dart';

//
//
// final userCommunityProvider = StreamProvider.autoDispose((ref) {
//   // final authChange = ref.watch(authStateChangeProvider);
//   // if (authChange.asData?.value != null) {
//   final communityControlller = ref.watch(communityConProvider.notifier);
//   return communityControlller.getUserCommunity();
//   // } else {
//   //   final communityControlller =
//   //       ref.watch(communityConProvider.notifier).dispose();
//   //   return Stream.empty();
//   // }
// });
final userCommunityProvider = StreamProvider.autoDispose((ref) {
  final communityControlller = ref.watch(communityConProvider.notifier);
  return communityControlller.getUserCommunity();
});
// final userCommunityProvider = StreamProvider.autoDispose((ref) {
//   final communityController = ref.watch(communityConProvider.notifier);

//   final user = ref.watch(userProvider);

//   ref.onDispose(() {
//     // Reset the user community value when the provider is disposed
//     communityController.
//   });

//   return communityController.getUserCommunity(user?.uid);
// });

//
final searchComuintyProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityConProvider.notifier).searchCommunity(query);
});

//
final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityConProvider.notifier).getCommunityPosts(name);
});

//
final getCommmuintyByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityConProvider.notifier).getCommunityByName(name);
});

final communityConProvider =
    StateNotifierProvider<CommunityControlller, bool>((ref) {
  final communityRespository = ref.watch(communityRepoProvider);
  final storageRepository = ref.watch(firebaseStorageProvider);
  return CommunityControlller(
      storageRepository: storageRepository,
      communityRespository: communityRespository,
      ref: ref);
});

class CommunityControlller extends StateNotifier<bool> {
  final CommunityRespository _communityRespository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  CommunityControlller({
    required CommunityRespository communityRespository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _communityRespository = communityRespository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //
  //
  // create commuinty
  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    // print(uid);`
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final result = await _communityRespository.createCommunity(community);
    // print(result.toString());
    state = false;
    result.fold((l) => showsnackBars(context, l.message), (r) {
      showsnackBars(context, 'Created Successfully');
      Routemaster.of(context).pop();
    });
  }

//
// edit community details
  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null || profileWebFile != null) {
      // communities/profile/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
        (l) => showsnackBars(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null || bannerWebFile != null) {
      // communities/banner/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
        (l) => showsnackBars(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRespository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showsnackBars(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  //
//
  void joinCommuinty(Community community, BuildContext context) async {
    final user = _ref.read(userProvider);

    Either<Failure, void> res;
    // var uid;
    if (community.members.contains(user!.uid)) {
      res =
          await _communityRespository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRespository.joinCommunity(community.name, user.uid);
    }
    res.fold((l) => showsnackBars(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showsnackBars(context, 'Commuinty Left Successfully');
      } else {
        showsnackBars(context, 'Commuinty Joined Successfully');
      }
    });
  }

  //
  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRespository.addMods(communityName, uids);
    res.fold(
      (l) => showsnackBars(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  //

//Searching query  coummnity
  Stream<List<Community>> searchCommunity(String query) {
    return _communityRespository.searchCommunity(query);
  }
  //

  //Community post display ui
  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRespository.getCommunityPost(name);
  }

  //
  // getting user community
  Stream<List<Community>> getUserCommunity() {
    // chnaged to watch
    final user = _ref.read(userProvider)!;

    return _communityRespository.getUserCommunity(user.uid);
    // return _communityRespository.
  }

  //
  //
  Stream<Community> getCommunityByName(String name) {
    print(name);
    return _communityRespository.getCommunityByName(name);
  }
}
