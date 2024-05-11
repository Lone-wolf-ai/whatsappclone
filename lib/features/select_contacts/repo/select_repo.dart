import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp/common/widgets/error.dart';
import 'package:whatsapp/features/models/usermodle.dart';
import 'package:whatsapp/features/chat/screen/mobile_chat_screen.dart';

final selectContactsRepoProvider =
    Provider((ref) => SelectContactRepo(firestore: FirebaseFirestore.instance));

class SelectContactRepo {
  final FirebaseFirestore firestore;

  SelectContactRepo({required this.firestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;
      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContact.phones[0].number
            .replaceAll(" ", "")
            .replaceAll("-", "");
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(context, MobileChatScreen.routeName,
              arguments: {'name': userData.name, 'uid': userData.uid});
        }
      }
      if (!isFound) {
        if (kDebugMode) {
          print("user not found");
        }
      }
    } catch (e) {
      ErrorScreen(s: e.toString());
    }
  }
}
