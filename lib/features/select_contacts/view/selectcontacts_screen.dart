import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:whatsapp/colors.dart';
import 'package:whatsapp/common/widgets/error.dart';
import 'package:whatsapp/features/select_contacts/controller/select_controller.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-screen';
  const SelectContactsScreen({super.key});

void selectContact(WidgetRef ref,Contact contact,BuildContext context){
  ref.read(SelectContactControllerProvider).selectContact(contact, context);
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: "Contact Screen".text.make(),
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ref.watch(getContactsProvider).when(
            data: (data) => ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final contact = data[index];
                    return InkWell(
                      onTap: ()=>selectContact(ref,contact,context),
                      child: ListTile(
                        title: contact.displayName.text.make(),
                        leading: contact.photo==null?null:CircleAvatar(backgroundImage:  MemoryImage(contact.photo!),),
                      ),
                    );
                  },
                ),
            error: (e, t) => ErrorScreen(s: e.toString()),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )),
      ),
    );
  }
}
