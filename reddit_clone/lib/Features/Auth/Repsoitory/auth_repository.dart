import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/Core/Constant/constants.dart';
import 'package:reddit_clone/Core/Constant/firebase_constant.dart';
import 'package:reddit_clone/Core/failure.dart';
import 'package:reddit_clone/Core/providers/firebase_provider.dart';
import 'package:reddit_clone/Core/type_def.dart';
import 'package:reddit_clone/Models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firebaseAuth: ref.read(authProvider),
    firebaseFirestore: ref.read(firestoreProvider),
    googleSignIn: ref.read(googlesigninProvider),
  ),
);

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final GoogleSignIn _googleSignIn;
  AuthRepository(
      {required FirebaseAuth firebaseAuth,
      required FirebaseFirestore firebaseFirestore,
      required GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth,
        _firebaseFirestore = firebaseFirestore,
        _googleSignIn = googleSignIn;

// user saved
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  // auth state changes
  Stream<User?> get authStateChanged => _firebaseAuth.authStateChanges();
  //
  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        googleAuthProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential =
            await _firebaseAuth.signInWithPopup(googleAuthProvider);
      } else {
        final GoogleSignInAccount? googleSignInAccount =
            await _googleSignIn.signIn();
        final googleauth = await googleSignInAccount?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleauth?.accessToken,
          idToken: googleauth?.idToken,
        );

        //

        if (isFromLogin) {
          userCredential = await _firebaseAuth.signInWithCredential(credential);
        } else {
          userCredential =
              await _firebaseAuth.currentUser!.linkWithCredential(credential);
        }
      }

      // usermodel used
      UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAns',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til'
          ],
          // gold award is not given it should given for premiuim;
        );

        _users.doc(userCredential.user!.uid).set(
              userModel.toMap(),
            );
      } else {
        userModel = await getUsersdata(userCredential.user!.uid).first;
      }
      return right(userModel);

      // print(userCredential.user?.email);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
    // return
  }

  //

  // Applying guest login feature
  FutureEither<UserModel> signInAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();

      // usermodel used
      UserModel userModel = UserModel(
        name: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
        // no award is not given it should given for login or signup;
      );

      _users.doc(userCredential.user!.uid).set(
            userModel.toMap(),
          );

      return right(userModel);

      // print(userCredential.user?.email);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
    // return
  }

  //

  // User data getting

  Stream<UserModel> getUsersdata(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  // Logout

  void logoutUser() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
