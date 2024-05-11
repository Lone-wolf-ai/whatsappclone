import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp/common/common_firebase/common_firebase.dart';
import 'package:whatsapp/common/enum/message_enum.dart';
import 'package:whatsapp/common/provider/message_reply_provider.dart';
import 'package:whatsapp/common/widgets/error.dart';
import 'package:whatsapp/features/models/chat_contact.dart';
import 'package:whatsapp/features/models/message_model.dart';
import 'package:whatsapp/features/models/usermodle.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);
});

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots() 
        .asyncMap((event) async {
      List<ChatContact> contacts = [];

      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());

        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();

        var user = UserModel.fromMap(userData.data()!);
        print(chatContact.contactId);
        contacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage));
      }

      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String reciverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> message = [];
      for (var document in event.docs) {
        message.add(Message.fromMap(document.data()));
      }
      return message;
    });
  }

//her its usrd for  save message....
  void _saveMessageToMessageSubcollection(
      {required String reciverUserID,
      required String text,
      required DateTime timeSent,
      required String username,
      required String meesageId,
      required reciverUsername,
      required MessageEnum messagetype,
      required MessageReply? messageReply,
      required String senderUsername,
      required String recieverUsername,
      required MessageEnum repliedMessageType}) async {
    final message = Message(
        senderId: auth.currentUser!.uid,
        reciverId: reciverUserID,
        text: text,
        type: messagetype,
        timeSent: timeSent,
        messageId: meesageId,
        isSeen: false,
        repliedTo: messageReply == null
            ? ''
            : messageReply.isMe
                ? senderUsername
                : recieverUsername,
        repliedMessage: messageReply == null ? '' : messageReply.message,
        repliedMessageType: repliedMessageType);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserID)
        .collection('messages')
        .doc(meesageId)
        .set(message.toMap());

    await firestore
        .collection('users')
        .doc(reciverUserID)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(meesageId)
        .set(
          message.toMap(),
        );
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel reciverUserData,
    String text,
    DateTime timeSent,
    String reciverUserId,
  ) async {
    var reciverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(reciverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(reciverChatContact.toMap());

    var senderrChatContact = ChatContact(
        name: reciverUserData.name,
        profilePic: reciverUserData.profilePic,
        contactId: reciverUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserId)
        .set(senderrChatContact.toMap());
  }

  void sendTextMessage(
      {required BuildContext context,
      required String text,
      required String reciverUserId,
      required MessageReply? messageReply,
      required UserModel senderUser}) async {
    try {
      var timeSent = DateTime.now();
      UserModel? reciverUserData;
      var messageId = const Uuid().v1();

      var userDataMap =
          await firestore.collection('users').doc(reciverUserId).get();

      reciverUserData = UserModel.fromMap(userDataMap.data()!);

      _saveDataToContactsSubcollection(
          senderUser, reciverUserData, text, timeSent, reciverUserId);

      _saveMessageToMessageSubcollection(
          reciverUserID: reciverUserId,
          text: text,
          timeSent: timeSent,
          username: senderUser.name,
          meesageId: messageId,
          messagetype: MessageEnum.text,
          reciverUsername: reciverUserData.name,
          repliedMessageType: messageReply == null
              ? MessageEnum.text
              : messageReply.messageEnum,
          messageReply: messageReply,
          recieverUsername: reciverUserData.name,
          senderUsername: senderUser.name);
    } catch (e) {
      print(e.toString());
    }
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required ProviderRef ref,
      required MessageEnum messageEnum,
      required String reciverUserId,
      required MessageReply? messageReply,
      required UserModel senderUserData}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      String fileurl = await ref
          .read(commonFirebaseStoreageRepoProvider)
          .storeFiletoFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$reciverUserId/$messageId',
              file);
      UserModel reciverUserData;
      var userDatamap =
          await firestore.collection('users').doc(reciverUserId).get();
      reciverUserData = UserModel.fromMap(userDatamap.data()!);
      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '🎬 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 audio';
          break;
        case MessageEnum.gif:
          contactMsg = '👻 GIF';
          break;
        default:
          contactMsg = '📷 Photo';
      }
      _saveDataToContactsSubcollection(
          senderUserData, reciverUserData, contactMsg, timeSent, reciverUserId);
      _saveMessageToMessageSubcollection(
        reciverUserID: reciverUserId,
        text: fileurl,
        timeSent: timeSent,
        username: senderUserData.name,
        meesageId: messageId,
        reciverUsername: reciverUserData.name,
        messagetype: messageEnum,
        messageReply: messageReply,
        senderUsername: senderUserData.name,
        recieverUsername: reciverUserData.name,
        repliedMessageType:
            messageReply == null ? MessageEnum.text : messageReply.messageEnum,
      );
    } catch (e) {
      ErrorScreen(s: e.toString());
    }
  }

  void seChatMessageSeen(BuildContext context,String reciverUserID,String messageId)async{
    try{
await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserID)
        .collection('messages')
        .doc(messageId)
        .update({'isSeen':true});

    await firestore
        .collection('users')
        .doc(reciverUserID)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .update({'isSeen':true});
    }catch(e){
      print(e.toString());
    }

  }
}
