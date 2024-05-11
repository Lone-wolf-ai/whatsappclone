import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/colors.dart';
import 'package:whatsapp/features/auth/controller/authcontroller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login_screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController phonecontroller = TextEditingController();
  Country? _country;

  void sendPhoneNumber() {
    String phoneNumber = phonecontroller.text.trim();
    if (_country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, "+${_country!.phoneCode}$phoneNumber");
          if(kDebugMode){
            print(phoneNumber);
          }
    }else{
      
        if (kDebugMode) {
          print("fill field");
        }
      
    }
  }

  void pickcountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country country) {
          setState(() {
            _country = country;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Enter your phone number".text.make(),
        backgroundColor: backgroundColor,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            30.heightBox,
            "WhatsApp will need to verify your phone number"
                .text
                .size(18)
                .semiBold
                .make(),
            40.heightBox,
            "pick country"
                .text
                .size(14)
                .blue100
                .make()
                .onTap(pickcountry)
                .box
                .p12
                .rounded
                .border(width: 0.6, color: Colors.blue)
                .make()
                .centered(),
            50.heightBox,
            Row(
              children: [
                if (_country != null)
                  "+${_country!.phoneCode}".text.make().box.p12.make(),
                TextField(
                  controller: phonecontroller,
                  decoration: const InputDecoration(hintText: "Phone Number"),
                ).box.width(300).make(),
              ],
            ).box.p12.make(),
            100.heightBox,
            "Next"
                .text
                .semiBold
                .size(14)
                .blue100
                .make()
                .onTap(sendPhoneNumber)
                .box
                .padding(
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10))
                .rounded
                .green700
                .border(width: 0.6, color: Colors.green)
                .make()
                .centered(),
          ],
        ),
      ),
    );
  }
}
