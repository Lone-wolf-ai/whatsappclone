import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/common/enum/message_enum.dart';
import 'package:whatsapp/common/provider/message_reply_provider.dart';
import 'package:whatsapp/features/chat/controller/chat_controller.dart';
import 'package:whatsapp/features/models/message_model.dart';
import 'package:whatsapp/features/chat/widgets/my_message_card.dart';
import 'package:whatsapp/features/chat/widgets/sender_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String reciverUserId;
  const ChatList({
    super.key,
    required this.reciverUserId,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messagecontroller = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messagecontroller.dispose();
  }

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref
        .read(messageReplyProvider.notifier)
        .update((state) => MessageReply(message, isMe, messageEnum));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream:
            ref.watch(chatControllerProvider).chatStream(widget.reciverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          SchedulerBinding.instance.addPostFrameCallback((notused) {
            messagecontroller
                .jumpTo(messagecontroller.position.maxScrollExtent);
          });

          return ListView.builder(
            controller: messagecontroller,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              var time = DateFormat.Hm().format(message.timeSent);
              if (!message.isSeen &&
                  message.reciverId == FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                    context, widget.reciverUserId, message.messageId);
              }
              if (message.senderId == FirebaseAuth.instance.currentUser!.uid) {
                return MyMessageCard(
                  message: message.text,
                  date: time,
                  type: message.type,
                  onLeftSwipe: (DragUpdateDetails details) {
                    var m = message.text;
                    var isMe = true;
                    var messageEnum = message.type;

                    onMessageSwipe(m, isMe, messageEnum);
                  },
                  repliedText: message.repliedMessage,
                  username: message.repliedTo,
                  repliedMessageType: message.repliedMessageType, isSeen: message.isSeen,
                );
              }
              return SenderMessageCard(
                message: message.text,
                date: time,
                type: message.type,
                onRightSwipe: (DragUpdateDetails details) {
                  var m = message
                      .text; // Assuming `message` is available in scope (e.g., from snapshot.data)
                  var isMe = false;
                  var messageEnum = message.type;

                  onMessageSwipe(m, isMe, messageEnum);
                },
                repliedText: message.repliedMessage,
                username: message.repliedTo,
                repliedMessageType: message.repliedMessageType,
              );
            },
          );
        });
  }
}
