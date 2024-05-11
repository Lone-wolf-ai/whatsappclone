// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp/features/auth/controller/authcontroller.dart';
import 'package:whatsapp/features/models/status_model.dart';

import 'package:whatsapp/features/status/repository/status_repo.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepo = ref.read(statusRepoProvider);
  return StatusController(statusRepo: statusRepo, ref: ref);
});

class StatusController {
  final StatusRepo statusRepo;
  final ProviderRef ref;
  StatusController({
    required this.statusRepo,
    required this.ref,
  });
  void addStatus(File file, BuildContext context) {
    ref.watch(userDataAuthProvider).whenData((value) {
      statusRepo.uploadStatus(
          username: value!.name,  
          profilePic: value.profilePic,
          phoneNumber: value.phoneNumber,
          statusImage: file,
          context: context);
    });
  }
  Future<List<Status>>getStatus(BuildContext context)async{
    List<Status>statuses=await statusRepo.getStatus(context);
    return statuses;
  }
}
