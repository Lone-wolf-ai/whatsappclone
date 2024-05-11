import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/features/auth/view/loginscreen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigatelogin(context){
    Navigator.pushNamed(context, LoginScreen.routeName);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            50.heightBox,
            "Welcom to Whats'app".text.bold.size(35).make().centered(),
            150.heightBox,
            const Icon(
              Icons.whatshot,
              size: 300,
            ).box.alignCenter.make(),
            100.heightBox,
            "Start"
                .text
                .white
                .size(20)
                .semiBold
                .make()
                .box
                .padding(
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 10))
                .roundedLg
                .green400
                .make().onTap(() {navigatelogin(context); }),
          ],
        ),
      ),
    );
  }
}
