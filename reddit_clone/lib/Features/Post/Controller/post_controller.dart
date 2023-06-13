import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/enums/enum.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Post/Repository/post_repo.dart';
import 'package:reddit_clone/Features/user_profile_Screen/Controller/userProfile_controller.dart';
import 'package:reddit_clone/Models/comments_model.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../Core/providers/stroage_repsoitory.dart';
import 'package:uuid/uuid.dart';
import '../../../Core/utils.dart';
import '../../../Models/postModel.dart';

final postConProvider = StateNotifierProvider<PostControlller, bool>((ref) {
  final postRepository = ref.watch(postRepoProvider);
  final storageRepository = ref.watch(firebaseStorageProvider);
  return PostControlller(
      storageRepository: storageRepository,
      postRespository: postRepository,
      ref: ref);
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communites) {
  final postControlller = ref.watch(postConProvider.notifier);
  return postControlller.festchUserCommuintyPosts(communites);
});

// Guest
final guestPostsProvider = StreamProvider((ref) {
  final postControlller = ref.watch(postConProvider.notifier);
  return postControlller.festchGuestPosts();
});

//
final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  return ref.watch(postConProvider.notifier).getPostById(postId);
});

class PostControlller extends StateNotifier<bool> {
  final PostRepository _postRespository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  PostControlller({
    required PostRepository postRespository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _postRespository = postRespository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String titletext,
    required Community selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: titletext,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [
        user.uid,
      ],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final res = await _postRespository.addPost(post);
    _ref
        .read(userProfileControlllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showsnackBars(context, l.message), (r) {
      showsnackBars(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  //
  void shareLinkPost({
    required BuildContext context,
    required String titletext,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;

    Post post = Post(
      id: postId,
      title: titletext,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.banner,
      upvotes: [
        user.uid,
      ],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRespository.addPost(post);
    _ref
        .read(userProfileControlllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;

    res.fold((l) => showsnackBars(context, l.message), (r) {
      showsnackBars(context, 'Post Created Successfully');
      Routemaster.of(context).pop();
    });
  }

  //
  void shareImagePost({
    required BuildContext context,
    required String titletext,
    required Community selectedCommunity,
    required File? image,
    required Uint8List? webFile,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final imageResult = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: image,
      webFile: webFile,
    );

    imageResult.fold((l) => showsnackBars(context, l.message), (r) async {
      Post post = Post(
        id: postId,
        title: titletext,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.banner,
        upvotes: [
          user.uid,
        ],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );

      final res = await _postRespository.addPost(post);
      _ref
          .read(userProfileControlllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;

      res.fold((l) => showsnackBars(context, l.message), (r) {
        showsnackBars(context, 'Post Created Successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  //
  void deletePost(Post post, BuildContext context) async {
    final res = await _postRespository.deletePost(post);
    _ref
        .read(userProfileControlllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);

    res.fold(
      (l) => showsnackBars(context, l.message),
      (r) => showsnackBars(context, 'Post Deleted Successfully'),
    );
  }

  // voting part

  void upVote(Post post) async {
    final user = _ref.read(userProvider)!;
    _postRespository.upVote(post, user.uid);
  }
  // voting part

  void downVote(Post post) async {
    final user = _ref.read(userProvider)!;
    _postRespository.downVote(post, user.uid);
  }

  //

  Stream<List<Post>> festchUserCommuintyPosts(List<Community> communites) {
    if (communites.isNotEmpty) {
      return _postRespository.festchUserCommuintyPosts(communites);
    } else {
      return Stream.value([]);
    }
  }

  // Guest

  Stream<List<Post>> festchGuestPosts() {
    return _postRespository.festchGuestPosts();
  }

  //

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRespository.awardPost(post, award, user.uid);

    res.fold((l) => showsnackBars(context, l.message), (r) {
      _ref
          .read(userProfileControlllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }

  //
  Stream<Post> getPostById(String postId) {
    return _postRespository.getPostById(postId);
  }
}
