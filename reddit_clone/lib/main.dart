import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/common/errorText.dart';
import 'package:reddit_clone/Core/common/loader.dart';
import 'package:reddit_clone/Features/Auth/Controllers/auth_controller.dart';
import 'package:reddit_clone/Models/user_model.dart';
import 'package:reddit_clone/router.dart';
import 'package:reddit_clone/themes/pallete.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:routemaster/routemaster.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;
  void getuserData(User data, WidgetRef ref) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUsersdata(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: ((data) => MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Reddit Clone',
                theme: ref.watch(themeNotifierProvider),
                routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
                  if (data != null) {
                    getuserData(data, ref);
                    if (userModel != null) {
                      return loggedInRoute;
                    }
                  }
                  return loggedOutRoute;
                }),
                routeInformationParser: const RoutemasterParser(),
              )),
          error: ((error, stackTrace) =>
              ErrorText(errorMessage: error.toString())),
          loading: () => const Loader(),
        );
  }
}
