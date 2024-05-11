import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/common/widgets/error.dart';
import 'package:whatsapp/features/auth/view/loginscreen.dart';
import 'package:whatsapp/features/auth/view/otp_Screen.dart';
import 'package:whatsapp/features/auth/view/user_info_screen.dart';
import 'package:whatsapp/features/group/screens/create_group_screen.dart';
import 'package:whatsapp/features/models/status_model.dart';
import 'package:whatsapp/features/select_contacts/view/selectcontacts_screen.dart';
import 'package:whatsapp/features/chat/screen/mobile_chat_screen.dart';
import 'package:whatsapp/features/status/screens/confirmstatus_screen.dart';
import 'package:whatsapp/features/status/screens/status_contactScreen.dart';

Route<dynamic> generateroute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());

    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => OTPScreen(
                verificationId: verificationId,
              ));

    case UserInfoScreen.routeName:
      return MaterialPageRoute(builder: (context) => const UserInfoScreen());

    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const SelectContactsScreen());

    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(name: name, uid: uid));
          
    case StatusScreen.routeName:
      final status = settings.arguments as Status;
      return MaterialPageRoute(
          builder: (context) => StatusScreen(status: status));

    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(
          builder: (context) => ConfirmStatusScreen(file: file));

    case CreateGroupScreen.routeName:
      return MaterialPageRoute(builder: (context) => const CreateGroupScreen());

    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
                body: ErrorScreen(s: "Error"),
              ));
  }
}
