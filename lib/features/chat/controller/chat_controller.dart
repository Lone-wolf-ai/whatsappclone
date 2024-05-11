import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp/common/enum/message_enum.dart';
import 'package:whatsapp/common/provider/message_reply_provider.dart';
import 'package:whatsapp/common/widgets/error.dart';
import 'package:whatsapp/features/auth/controller/authcontroller.dart';
import 'package:whatsapp/features/chat/repo/chat_repo.dart';
import 'package:whatsapp/features/models/chat_contact.dart';
import 'package:whatsapp/features/models/message_model.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  ChatController({required this.chatRepository, required this.ref});

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatStream(String reciverUserId) {
    return chatRepository.getChatStream(reciverUserId);
  }

  void sendTextMessage(
      BuildContext context, String text, String reciverUserId) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).when(
        data: (data) => chatRepository.sendTextMessage(
            context: context,
            text: text,
            reciverUserId: reciverUserId,
            senderUser: data!,
            messageReply: messageReply),
        error: (e, t) => ErrorScreen(
              s: e.toString(),
            ),
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendFileMessage(BuildContext context, File file, String reciverUserId,
      MessageEnum messageEnum) {
    final messageReply = ref.read(messageReplyProvider);

    ref.read(userDataAuthProvider).when(
        data: (data) => chatRepository.sendFileMessage(
            context: context,
            reciverUserId: reciverUserId,
            senderUserData: data!,
            file: file,
            ref: ref,
            messageEnum: messageEnum,
            messageReply: messageReply),
        error: (e, t) => ErrorScreen(
              s: e.toString(),
            ),
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }
  void setChatMessageSeen(BuildContext context ,String reciverUserId,String messageId){
    chatRepository.seChatMessageSeen(context, reciverUserId, messageId);
  }
}
