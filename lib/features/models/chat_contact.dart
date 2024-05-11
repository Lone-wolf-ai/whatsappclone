// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatContact {
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;

  ChatContact(
      {required this.name,
      required this.profilePic,
      required this.contactId,
      required this.timeSent,
      required this.lastMessage});

  

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      name:map['name']??"",
      profilePic:map['profilePic']??"",
      contactId:map['contactId']??"",
      timeSent:DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      lastMessage:map['lastMessage']??"",
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatContact.fromJson(String source) => ChatContact.fromMap(json.decode(source) as Map<String, dynamic>);
}
