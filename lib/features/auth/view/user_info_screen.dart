import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/colors.dart';
import 'package:whatsapp/features/auth/controller/authcontroller.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const String routeName = "/user_info";
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  File? img;
  TextEditingController namecontroller = TextEditingController();
  Future<void> setImage() async {
    final pickedImage = await pickImage();
    setState(() {
      img = pickedImage;
    });
  }

  void storeUserData() async {
    String name = namecontroller.text.trim();
    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .saveUserdataToFirebase(name, img, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
        ),
        body: Column(
          children: [
            Stack(
              children: [
                (img == null)
                    ? CircleAvatar(
                        radius: 50,
                        backgroundColor: Vx.gray500,
                        child: Image.asset(
                          "assets/Default_pfp.svg.png",
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      ).centered()
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: Vx.gray500,
                        backgroundImage: FileImage(img!),
                      ).centered(),
                const Icon(
                  Icons.add_a_photo_rounded,
                  size: 30,
                )
                    .box
                    .margin(const EdgeInsets.only(left: 175, right: 175))
                    .padding(const EdgeInsets.all(3))
                    .bottomRounded(value: 40)
                    .make()
                    .onTap(setImage)
                    .positioned(right: 0, left: 0, bottom: 1),
              ],
            ),
            40.heightBox,
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: namecontroller,
                  decoration:
                      const InputDecoration(hintText: "Enter your name"),
                )),
                50.heightBox,
            ElevatedButton(
              onPressed: storeUserData,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
              child: "Save".text.white.make(),
            )
          ],
        ),
      ),
    );
  }
}

Future<File?> pickImage() async {
  File? img;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      img = File(pickedImage.path);
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
  return img;
}
