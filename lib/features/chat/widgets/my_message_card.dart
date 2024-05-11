import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/colors.dart';
import 'package:whatsapp/common/enum/message_enum.dart';
import 'package:whatsapp/features/chat/widgets/display_text_image.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final void Function(DragUpdateDetails details) onLeftSwipe;
  final String repliedText;
  final String username;
  final bool isSeen;
  final MessageEnum repliedMessageType;
  const MyMessageCard(
      {super.key,
      required this.message,
      required this.date,
      required this.type,
      required this.onLeftSwipe,
      required this.repliedText,
      required this.username,
      required this.isSeen,
      required this.repliedMessageType});

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onLeftSwipe: onLeftSwipe,
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: messageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                (type == MessageEnum.text)
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
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 2,
                          top: 5,
                          bottom: 25,
                        ),
                        child: DisplyTextImageGif(
                          message: message,
                          type: type,
                        )),
                Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ).pLTRB(10, 0, 0, 0),
                      
                       Icon(
                        isSeen?Icons.done_all:Icons.done,
                        size: 20,
                        color: isSeen?Colors.blue:Colors.white60,
                      ),
                    ],
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
