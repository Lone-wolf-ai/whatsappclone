// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp/features/auth/repo/auth_repo.dart';
import 'package:whatsapp/features/models/usermodle.dart';

final authControllerProvider = Provider((ref) {
  final authrepository = ref.watch(authrepoProvider);
  return Authcontroller(authRepository: authrepository, ref: ref);
});

final userDataAuthProvider=FutureProvider((ref){
  final authcontroller=ref.watch(authControllerProvider);
  return authcontroller.getUserData();
});

class Authcontroller {
  final AuthRepository authRepository;
  final ProviderRef ref;
  Authcontroller({
    required this.authRepository,
    required this.ref,
  });

Stream<UserModel>userDataById(String userId){
  return authRepository.userData(userId);
}

  Future<UserModel?>getUserData()async{
    UserModel?user=await authRepository.getCurrentUserData();
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.signInWithPhoneNumber(phoneNumber, context);
  }

  void otpverify(BuildContext context, String verificationId, String userOTP) {
    authRepository.verifyOTP(
        context: context, verificationId: verificationId, userOTP: userOTP);
  }

  void saveUserdataToFirebase(
      String name, File? profilePic, BuildContext context) {
    authRepository.saveUserdata(
        name: name, profilePic: profilePic, ref: ref, context: context);
  }
  void setUserState(bool isOnline){
    authRepository.setUserState(isOnline);
  }
}
