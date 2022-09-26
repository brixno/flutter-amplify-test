import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';

class StorageService {
  // 1
  late final imageUrlsController = StreamController<List<String>>();

  // 2
  void getImages() async {
    try {
      // 3
      final listOptions =
      S3ListOptions(accessLevel: StorageAccessLevel.private);
      // 4
      final result = await Amplify.Storage.list(options: listOptions);

      // 5
      final getUrlOptions =
      GetUrlOptions(accessLevel: StorageAccessLevel.private);
      // 6
      final List<String> imageUrls =
      await Future.wait(result.items.map((item) async {
        final urlResult =
        await Amplify.Storage.getUrl(key: item.key, options: getUrlOptions);
        return urlResult.url;
      }));

      // 7
      imageUrlsController.add(imageUrls);

      // 8
    } catch (e) {
      print('Storage List error - $e');
    }
  }

  void uploadImageAtPath(String imagePath) async {
    final imageFile = XFile(imagePath);
    File file = File(imageFile.path);
    // 2
    final imageKey = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      // 3
      final options = S3UploadFileOptions(
          accessLevel: StorageAccessLevel.private);

      // 4
      await Amplify.Storage.uploadFile(
          local: file, key: imageKey, options: options);

      // 5
      getImages();
    } catch (e) {
      print('upload error - $e');
    }
  }
}