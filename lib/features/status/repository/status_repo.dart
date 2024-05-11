// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp/common/common_firebase/common_firebase.dart';
import 'package:whatsapp/features/models/status_model.dart';
import 'package:whatsapp/features/models/usermodle.dart';

final statusRepoProvider = Provider(
  (ref) => StatusRepo(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      ref: ref),
);

class StatusRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  StatusRepo({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus(
      {required String username,
      required String profilePic,
      required String phoneNumber,
      required File statusImage,
      required BuildContext context}) async {
    try {
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      var imageUrl = await ref
          .read(commonFirebaseStoreageRepoProvider)
          .storeFiletoFirebase('/status/$statusId$uid', statusImage);
      List<Contact> contacts = [];

      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      List<String> uidWhoCanSee = [];
      for (int i = 0; i < contacts.length; i++) {
        var userDataFireBase = await firestore
            .collection('users')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(" ", '').replaceAll('-', ''))
            .get();
        if (userDataFireBase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDataFireBase.docs[0].data());
          uidWhoCanSee.add(userData.uid);
        }
      }
      List<String> statusImageUrls = [];
      var statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .get();
      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);

        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({'photoUrl': statusImageUrls});
            return;
      } else {
        statusImageUrls = [imageUrl];
      }

      Status status = Status(
          uid: uid,
          username: username,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          profilePic: profilePic,
          statusId: statusId,
          photoUrl: statusImageUrls,
          whoCanSee: uidWhoCanSee);

      await firestore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      for (int i = 0; i < contacts.length; i++) {
        var statusesSnapshot = await firestore
            .collection('status')
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ).replaceAll('-', ''),
            )
            .where(
              'createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch,
            )
            .get();  
         
        for (var tempData in statusesSnapshot.docs){
          Status tempStatus = Status.fromMap(tempData.data());
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
            print(statusData);
            
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
      //showSnackBar(context: context, content: e.toString());
    }
    return statusData;
  }

}
