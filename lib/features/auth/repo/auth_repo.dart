import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp/common/common_firebase/common_firebase.dart';
import 'package:whatsapp/features/auth/view/otp_Screen.dart';
import 'package:whatsapp/features/auth/view/user_info_screen.dart';
import 'package:whatsapp/features/models/usermodle.dart';
import 'package:whatsapp/screens/mobile_layout_screen.dart';

final authrepoProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
  },
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository(this.auth, this.firestore);

  Future<UserModel?> getCurrentUserData() async {
    UserModel? user;
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
      return user;
    }
  }

  void signInWithPhoneNumber(String phonenumber, BuildContext context) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phonenumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            throw e.message!;
          },
          codeSent: (String verificationId, int? resendToken) async {
            Navigator.pushNamed(context, OTPScreen.routeName,
                arguments: verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInfoScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Stream<UserModel> userData(String userID) {
    return firestore
        .collection('users')
        .doc(userID)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  void saveUserdata(
      {required String name,
      required File? profilePic,
      required ProviderRef ref,
      required BuildContext context}) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl = '';
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStoreageRepoProvider)
            .storeFiletoFirebase('profilePic/$uid', profilePic);
      }
      //created usermodel data class for store data
      var user = UserModel(
          name: name,
          uid: uid,
          profilePic: photoUrl,
          phoneNumber: auth.currentUser!.phoneNumber!,
          isonline: true,
          groupId: []);
      //it sends data to firebase
      await firestore.collection('users').doc(uid).set(user.toMap());
// Here its to navigate to mobile layout screen.after sending data to firebase.
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MobileLayoutScreen()),
          (route) => false);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

void setUserState(bool isonline)async{
  await firestore.collection('users').doc(auth.currentUser!.uid).update({'isonline':isonline});
}

}
