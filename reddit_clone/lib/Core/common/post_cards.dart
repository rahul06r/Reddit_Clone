// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/Constant/constants.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Features/Community/Controllers/community_controller.dart';
import 'package:reddit_clone/Features/Post/Controller/post_controller.dart';
import 'package:reddit_clone/Responsive%20Materials/responsive_W.dart';
import 'package:reddit_clone/themes/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../Models/postModel.dart';
import 'package:any_link_preview/any_link_preview.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postConProvider.notifier).deletePost(post, context);
  }

  void upVotePost(WidgetRef ref) async {
    ref.read(postConProvider.notifier).upVote(post);
  }

  void downVotePost(WidgetRef ref) async {
    ref.read(postConProvider.notifier).downVote(post);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push("/u/${post.uid}");
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push("/r/${post.communityName}");
  }

  void navigateTocomments(BuildContext context) {
    Routemaster.of(context).push("/post/${post.id}/comments");
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref.read(postConProvider.notifier).awardPost(
          award: award,
          context: context,
          post: post,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypedImage = post.type == 'image';
    final isTypedLink = post.type == 'link';
    final isTypedtext = post.type == 'text';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isNotUser = !user.isAuthenticated;
    return SafeArea(
      child: ResponsiveW(
        child: Container(
            child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: currentTheme.drawerTheme.backgroundColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kIsWeb)
                    Column(
                      children: [
                        IconButton(
                          onPressed: isNotUser ? () {} : () => upVotePost(ref),
                          icon: Icon(
                            Constants.up,
                            size: 30,
                            color: post.upvotes.contains(user.uid)
                                ? Pallete.redColor
                                : null,
                          ),
                        ),
                        Text(
                          '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              isNotUser ? () {} : () => downVotePost(ref),
                          icon: Icon(
                            Constants.down,
                            size: 30,
                            color: post.downvotes.contains(user.uid)
                                ? Pallete.blueColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  // for mobile code
                  //
                  Expanded(
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16)
                              .copyWith(right: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            navigateToCommunity(context),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            post.communityProfilePic,
                                          ),
                                          radius: 16,
                                          // chnage to 18 if needed
                                        ),
                                      ),

                                      //
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'r/${post.communityName}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  '1d',
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            GestureDetector(
                                              onTap: () =>
                                                  navigateToUser(context),
                                              child: Text(
                                                'r/${post.username}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                // alignment: Alignment(x, y),
                                                alignment: Alignment.center,
                                                actions: [
                                                  ListTile(
                                                    title: Text('Save'),
                                                    leading:
                                                        Icon(Icons.save_alt),
                                                  ),
                                                  ListTile(
                                                    title: Text('Share'),
                                                    leading: Icon(Icons.share),
                                                  ),
                                                  if (post.uid == user.uid)
                                                    ListTile(
                                                      onTap: () => deletePost(
                                                          ref, context),
                                                      title: Text('Delete'),
                                                      leading:
                                                          Icon(Icons.delete),
                                                    ),
                                                  // actuallly bottom sheet is used for this i used simple grid view
                                                  ListTile(
                                                    title: Text('Award'),
                                                    leading: Icon(
                                                      Icons
                                                          .card_giftcard_outlined,
                                                    ),
                                                    onTap: isNotUser
                                                        ? () {}
                                                        : () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        Dialog(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(20),
                                                                            child:
                                                                                GridView.builder(
                                                                              shrinkWrap: true,
                                                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                crossAxisCount: 4,
                                                                              ),
                                                                              itemCount: user.awards.length,
                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                final award = user.awards[index];
                                                                                return GestureDetector(
                                                                                  onTap: () => awardPost(ref, award, context),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Image.asset(Constants.awards[award]!),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ));
                                                          },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      icon: Icon(Icons.more_vert)),
                                  //
                                  // if (post.uid == user.uid)
                                  //   IconButton(
                                  //     onPressed: () => deletePost(ref, context),
                                  //     icon: Icon(
                                  //       Icons.delete,
                                  //       color: Pallete.redColor,
                                  //     ),
                                  //   ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (post.awards.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                SizedBox(
                                    height: 25,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: post.awards.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final award = post.awards[index];
                                        return Padding(
                                          // u can remove padding here if u want
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Image.asset(
                                            Constants.awards[award]!,
                                            height: 23,
                                          ),
                                        );
                                      },
                                    )),
                              ],
                              const SizedBox(height: 5),
                              if (isTypedImage)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .35,
                                  width: double.infinity,
                                  child: Image.network(
                                    post.link!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 5),
                              if (isTypedLink)
                                Container(
                                  // height: 150,
                                  // width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: AnyLinkPreview(
                                    link: post.link!,
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                  ),
                                ),
                              const SizedBox(height: 5),
                              if (isTypedtext)
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    post.description!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!kIsWeb)
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: isNotUser
                                              ? () {}
                                              : () => upVotePost(ref),
                                          icon: Icon(
                                            Constants.up,
                                            size: 30,
                                            color:
                                                post.upvotes.contains(user.uid)
                                                    ? Pallete.redColor
                                                    : null,
                                          ),
                                        ),
                                        Text(
                                          // '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                          '${post.upvotes.length - post.downvotes.length}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: isNotUser
                                              ? () {}
                                              : () => downVotePost(ref),
                                          icon: Icon(
                                            Constants.down,
                                            size: 30,
                                            color: post.downvotes
                                                    .contains(user.uid)
                                                ? Pallete.blueColor
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  GestureDetector(
                                    onTap: () => navigateTocomments(context),
                                    child: Row(
                                      children: [
                                        Icon(Icons.comment),
                                        SizedBox(width: 7),
                                        Text(
                                          // '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                          '${post.commentCount}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // mods

                                  ref
                                      .watch(getCommmuintyByNameProvider(
                                          post.communityName))
                                      .when(
                                          data: (data) {
                                            if (data.mods.contains(user.uid)) {
                                              return IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          actionsAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          actions: [
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Approve post'),
                                                              leading: Icon(
                                                                  Icons.done),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Remove post'),
                                                              leading: Icon(Icons
                                                                  .highlight_remove_outlined),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Remove as spam'),
                                                              leading: Icon(Icons
                                                                  .playlist_remove_sharp),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Lock comments'),
                                                              leading: Icon(
                                                                  Icons.lock),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Distinguish as mods'),
                                                              leading: Icon(Icons
                                                                  .add_moderator),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Unsticky Post'),
                                                              leading: Icon(Icons
                                                                  .push_pin),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Mark spoiler'),
                                                              leading: Icon(Icons
                                                                  .add_alert_rounded),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Mark NSFW'),
                                                              leading: Icon(Icons
                                                                  .eighteen_up_rating_sharp),
                                                            ),
                                                            ListTile(
                                                              onTap: () {},
                                                              title: Text(
                                                                  'Adjust crowd control'),
                                                              leading: Icon(Icons
                                                                  .signal_cellular_alt),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                icon: const Icon(
                                                  Icons.admin_panel_settings,
                                                ),
                                              );
                                            } else {
                                              return const SizedBox();
                                            }
                                          },
                                          error: (e, stacktrace) => ErrorText(
                                              errorMessage: e.toString()),
                                          loading: () => const Loader()),

                                  //change the icon to share
                                  // share count code is same has previous code
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.share,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Text(
                                            // '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                            '${post.commentCount}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // IconButton(
                                  //   onPressed: isNotUser
                                  //       ? () {}
                                  //       : () {
                                  //           showDialog(
                                  //               context: context,
                                  //               builder: (context) => Dialog(
                                  //                     child: Padding(
                                  //                       padding:
                                  //                           const EdgeInsets
                                  //                               .all(20),
                                  //                       child: GridView.builder(
                                  //                         shrinkWrap: true,
                                  //                         gridDelegate:
                                  //                             const SliverGridDelegateWithFixedCrossAxisCount(
                                  //                           crossAxisCount: 4,
                                  //                         ),
                                  //                         itemCount: user
                                  //                             .awards.length,
                                  //                         itemBuilder:
                                  //                             (BuildContext
                                  //                                     context,
                                  //                                 int index) {
                                  //                           final award = user
                                  //                               .awards[index];
                                  //                           return GestureDetector(
                                  //                             onTap: () =>
                                  //                                 awardPost(
                                  //                                     ref,
                                  //                                     award,
                                  //                                     context),
                                  //                             child: Padding(
                                  //                               padding:
                                  //                                   const EdgeInsets
                                  //                                           .all(
                                  //                                       8.0),
                                  //                               child: Image.asset(
                                  //                                   Constants
                                  //                                           .awards[
                                  //                                       award]!),
                                  //                             ),
                                  //                           );
                                  //                         },
                                  //                       ),
                                  //                     ),
                                  //                   ));
                                  //         },
                                  //   icon: const Icon(
                                  //     Icons.card_giftcard_outlined,
                                  //   ),
                                  // )
                                ],
                              )

                              //
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        )),
      ),
    );
  }
}
