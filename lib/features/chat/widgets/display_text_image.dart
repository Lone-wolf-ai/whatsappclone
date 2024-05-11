// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:whatsapp/common/enum/message_enum.dart';
import 'package:whatsapp/features/chat/widgets/video_player.dart';

class DisplyTextImageGif extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplyTextImageGif({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    bool isplaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(fontSize: 16),
          )
        : (type == MessageEnum.audio)
            ? StatefulBuilder(builder: (context, setState) {
                return IconButton(
                    constraints: const BoxConstraints(minWidth: 100),
                    onPressed: () async {
                      if (isplaying) {
                        await audioPlayer.pause();
                        setState(() {
                          isplaying = false;
                        });
                      } else {
                        await audioPlayer.play(UrlSource(message));
                         setState(() {
                          isplaying = true;
                        });
                      }
                    },
                    icon:  Icon(isplaying?Icons.pause:Icons.play_arrow_rounded));
              })
            : type == MessageEnum.video
                ? VideoPlayerItem(videoUrl: message)
                : CachedNetworkImage(
                    imageUrl: message,
                    fit: BoxFit.fitHeight,
                    height: 300,
                  );
  }
}
