import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/enums/enum.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/user_profile_Screen/Repository/user_profile_repo.dart';
import 'package:reddit_clone/Models/user_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../Core/providers/stroage_repsoitory.dart';
import '../../../Core/utils.dart';
import '../../../Models/postModel.dart';

final userProfileControlllerProvider =
    StateNotifierProvider<UserProfileControlller, bool>((ref) {
  final userProfileRespository = ref.watch(userprofileeditRepoProvider);
  final storageRepository = ref.watch(firebaseStorageProvider);
  return UserProfileControlller(
      storageRepository: storageRepository,
      userProfileRespository: userProfileRespository,
      ref: ref);
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControlllerProvider.notifier).getUserPosts(uid);
});

class UserProfileControlller extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  UserProfileControlller({
    required UserProfileRepository userProfileRespository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _userProfileRepository = userProfileRespository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //
  // edit community details
  void editProfile({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null || profileWebFile != null) {
      // communities/profile/memes

      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
        (l) => showsnackBars(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    if (bannerFile != null || bannerWebFile != null) {
      // communities/banner/memes
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
        (l) => showsnackBars(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }

    //
    user = user.copyWith(name: name);

    final res = await _userProfileRepository.editProfileUser(user);
    state = false;
    res.fold(
      (l) => showsnackBars(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }

  void updateUserKarma(UserKarma userKarma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + userKarma.karma);
    final res = await _userProfileRepository.updateUserKarma(user);
    // ?updating the state;
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  //
}
