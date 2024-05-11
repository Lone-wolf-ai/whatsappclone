import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/features/auth/controller/authcontroller.dart';

class OTPScreen extends ConsumerWidget {
  final String verificationId;
  static const String routeName = '/otp-screen';
  const OTPScreen({super.key, required this.verificationId});

  void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    ref
        .read(authControllerProvider)
        .otpverify(context, verificationId, userOTP);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: "OTP Screen".text.make(),
      ),
      body: Column(
        children: [
          30.heightBox,
          "We have an SMS with a code".text.size(20).make().centered(),
          30.heightBox,
          SizedBox(
              width: 180,
              child: TextField(
                onChanged: (userOTP) {
                  if(userOTP.length==6){
                    verifyOTP(ref, context, userOTP.trim());
                  }
                },
                maxLength: 6,
                style: const TextStyle(fontSize: 30, letterSpacing: 5),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    hintText: "_ _ _ _ _ _",
                    hintStyle: TextStyle(fontSize: 30)),
              ))
        ],
      ),
    );
  }
}
