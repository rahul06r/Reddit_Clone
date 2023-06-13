import 'package:flutter/material.dart';
import 'package:reddit_clone/Features/Auth/Screens/login_screen.dart';
import 'package:reddit_clone/Features/Community/Screens/community_screen_details.dart';
import 'package:reddit_clone/Features/Community/Screens/create_community_screens.dart';
import 'package:reddit_clone/Features/Community/Screens/edit_comunity_screen.dart';
import 'package:reddit_clone/Features/Community/Screens/mod_tools_screen.dart';
import 'package:reddit_clone/Features/Feeds/Screens/add_post_type_Screen.dart';
import 'package:reddit_clone/Features/Home/Screens/homeScreen.dart';
import 'package:reddit_clone/Features/Post/Screens/comments_post.dart';
import 'package:reddit_clone/Features/user_profile_Screen/Screens/edit_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

import 'Features/Community/Screens/moderators_edit_screen.dart';
import 'Features/user_profile_Screen/Screens/user_profile.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

//
final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: HomeScreen(),
      ),
  //
  //
  '/create-community': (_) => const MaterialPage(
        child: CreateCommunityScreen(),
      ),
  //
  //

  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )),

  //
  //
  '/mod-tools/:name': (routedata) => MaterialPage(
        child: ModToolsScreen(
          name: routedata.pathParameters['name']!,
        ),
      ),

  '/edit-community/:name': (routedata) => MaterialPage(
        child: EditCommunityScreen(
          name: routedata.pathParameters['name']!,
        ),
      ),
  //
  //
  '/edit-members/:name': (routedata) => MaterialPage(
        child: ModeratorEditScreen(
          name: routedata.pathParameters['name']!,
        ),
      ),

  //
  //
  '/u/:uid': (routedata) => MaterialPage(
        child: UserProfileScreen(
          uid: routedata.pathParameters['uid']!,
        ),
      ),

  //
  '/edit_profile/:uid': (routedata) => MaterialPage(
        child: EditProfileSCreen(
          uid: routedata.pathParameters['uid']!,
        ),
      ),

  //
  '/add_post/:type': (routedata) => MaterialPage(
        child: AddPostTypeScreen(
          type: routedata.pathParameters['type']!,
        ),
      ),

  //
  '/post/:postId/comments': (route) => MaterialPage(
        child: CommentPost(
          postID: route.pathParameters['postId']!,
        ),
      ),

// change name here bcz it casue routing problem
  // '/add_post/': (routedata) => const MaterialPage(
  //       child: AddPostScreen(),
  //     ),
});
