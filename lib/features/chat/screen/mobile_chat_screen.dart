import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:whatsapp/colors.dart';
import 'package:whatsapp/features/auth/controller/authcontroller.dart';
import 'package:whatsapp/features/chat/widgets/bottom_nav.dart';
import 'package:whatsapp/features/models/usermodle.dart';
import 'package:whatsapp/info.dart';
import 'package:whatsapp/features/chat/widgets/chat_list.dart';

class MobileChatScreen extends ConsumerWidget {
  static const routeName = '/chat-screen';
  final String name;
  final String uid;
  const MobileChatScreen({
    super.key,
    required this.name,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: StreamBuilder(
          stream: ref.read(authControllerProvider).userDataById(uid),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            UserModel userdata = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                Text(
                  userdata.isonline == true ? 'Online' : 'Offline',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                )
              ],
            );
          },
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              print(name);
            },
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
           Expanded(
            child: ChatList(
              reciverUserId:uid,
            ),
          ),
          BottomNav(
            reciverUserId: uid,
          ),
        ],
      ),
    );
  }
}
