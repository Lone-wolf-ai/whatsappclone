import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commonFirebaseStoreageRepoProvider = Provider((ref) =>
    CommonFirebaseStorageRepo(firebaseStorage: FirebaseStorage.instance));

class CommonFirebaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  CommonFirebaseStorageRepo({required this.firebaseStorage});

  Future<String> storeFiletoFirebase(String ref, File file) async {
    UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadurl = await snap.ref.getDownloadURL();
    return downloadurl;
  }
}
