import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp/features/select_contacts/repo/select_repo.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactRepo = ref.watch(selectContactsRepoProvider);
  return selectContactRepo.getContacts();
});

final SelectContactControllerProvider = Provider((ref) {
  final selectContactRepo = ref.watch(selectContactsRepoProvider);
  return SelectContactController(
      ref: ref,
      selectContactRepo: selectContactRepo);
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepo selectContactRepo;

  SelectContactController({required this.ref, required this.selectContactRepo});

  void selectContact(Contact selectedContact, BuildContext context) {
    selectContactRepo.selectContact(selectedContact, context);
  }
}
