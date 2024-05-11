import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/colors.dart';
import 'package:whatsapp/features/chat/controller/chat_controller.dart';
import 'package:whatsapp/features/chat/repo/chat_repo.dart';
import 'package:whatsapp/features/models/chat_contact.dart';
import 'package:whatsapp/features/chat/screen/mobile_chat_screen.dart';

class ContactsList extends ConsumerWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: StreamBuilder<List<ChatContact>>(
          stream:ref.watch(chatControllerProvider).chatContacts(),
          builder: (context, snapshot) {
          
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //print(snapshot.data==null?"nulll":"no");
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var chatcontact = snapshot.data![index];

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, MobileChatScreen.routeName,
                            arguments: {
                              'name': chatcontact.name,
                              'uid': chatcontact.contactId
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            chatcontact.name,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              chatcontact.lastMessage,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          leading: (chatcontact.profilePic != "")
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatcontact.profilePic,
                                  ),
                                  radius: 30,
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  child:
                                      Image.asset("assets/Default_pfp.svg.png"),
                                ),
                          trailing: Text(
                            DateFormat.Hm().format(chatcontact.timeSent),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: dividerColor, indent: 85),
                  ],
                );
              },
            );
          }),
    );
  }
}
