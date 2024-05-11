import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/colors.dart';
import 'package:whatsapp/common/enum/message_enum.dart';
import 'package:whatsapp/features/chat/widgets/display_text_image.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.onRightSwipe,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
  });
  final String message;
  final String date;
  final MessageEnum type;
  final void Function(DragUpdateDetails details) onRightSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: senderMessageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 30,
                    top: 5,
                    bottom: 20,
                  ),
                  child: (type == MessageEnum.text)
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 30,
                            top: 5,
                            bottom: 20,
                          ),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isReplying) ...[
                              
                              Text(
                                username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              DisplyTextImageGif(
                                message: repliedText,
                                type: repliedMessageType,
                              )
                                  .box.p12
                                  .margin(const EdgeInsets.symmetric(horizontal: 5))
                                  .roundedSM
                                  .color(backgroundColor.withOpacity(0.5))
                                  .make()
                            ],
                            DisplyTextImageGif(
                              message: message,
                              type: type,
                            ),
                          ],
                        ))
                      : Padding(
                          padding: const EdgeInsets.only(
                            left: 5,
                            right: 5,
                            top: 5,
                            bottom: 25,
                          ),
                          child: DisplyTextImageGif(
                            message: message,
                            type: type,
                          )),
                ),
                Positioned(
                  bottom: 2,
                  right: 10,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
