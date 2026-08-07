import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MediaService {
  MediaService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<List<XFile>> pickImages() {
    return _picker.pickMultiImage(imageQuality: 100, limit: 10);
  }

  Future<XFile?> pickVideo() {
    return _picker.pickVideo(source: ImageSource.gallery);
  }

  Future<XFile?> compressImage(XFile source, {int quality = 82}) async {
    final directory = await getTemporaryDirectory();
    final target = File(
      '${directory.path}/sf_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    return FlutterImageCompress.compressAndGetFile(
      source.path,
      target.path,
      quality: quality,
      minWidth: 1600,
      minHeight: 1600,
      keepExif: true,
    );
  }
}
