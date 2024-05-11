import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/colors.dart';
import 'package:whatsapp/common/enum/message_enum.dart';
import 'package:whatsapp/common/provider/message_reply_provider.dart';
import 'package:whatsapp/features/auth/view/user_info_screen.dart';
import 'package:whatsapp/features/chat/controller/chat_controller.dart';
import 'package:whatsapp/features/chat/widgets/message_reply_preview.dart';

class BottomNav extends ConsumerStatefulWidget {
  final String reciverUserId;

  const BottomNav({required this.reciverUserId, super.key});

  @override
  ConsumerState<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<BottomNav> {
  TextEditingController _messageController = TextEditingController();
  bool isrecorderInit = false;
  bool isrecording = false;
  FlutterSoundRecorder? _soundRecorder;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Permission didnt give");
    }
    await _soundRecorder!.openRecorder();
    isrecorderInit = true;
  }

  bool isShow = false;
  void sendTextMessage() async {
    if (isShow) {
      ref.read(chatControllerProvider).sendTextMessage(
          context, _messageController.text.trim(), widget.reciverUserId);
      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempdir = await getTemporaryDirectory();
      var path = '${tempdir.path}/flutter_sound.aac';

      if (!isrecorderInit) return;

      if (isrecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(toFile: path);
      }
      setState(() {
        isrecording = !isrecording;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isrecorderInit = false;
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.reciverUserId, messageEnum);
  }

  void selectImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      final imageFile = File(result.path);
      sendFileMessage(imageFile, MessageEnum.image);
    } else {
      print("No image selected.");
    }
  }

  void selectVideo() async {
    final picker = ImagePicker();
    final result = await picker.pickVideo(source: ImageSource.gallery);

    if (result != null) {
      final imageFile = File(result.path);
      sendFileMessage(imageFile, MessageEnum.video);
    } else {
      print("No video selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isshowMessageReply = messageReply != null;
    return Column(
      children: [
        isshowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _messageController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        isShow = true;
                      });
                    } else {
                      setState(() {
                        isShow = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Type your message here....",
                    filled: true,
                    fillColor: mobileChatBoxColor,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: SizedBox(
                        width: 65,
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 7),
                              child: Icon(
                                Icons.gif_box_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 10),
                      child: SizedBox(
                        width: 75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                            ).onTap(selectImage),
                            const Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                            ).onTap(selectVideo)
                          ],
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: CircleAvatar(
                  backgroundColor: Colors.green[600],
                  child: GestureDetector(
                    onTap: sendTextMessage,
                    child: isShow
                        ? const Icon(Icons.send)
                        : Icon(isrecording ? Icons.close : Icons.mic),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
