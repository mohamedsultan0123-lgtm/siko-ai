import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class AvatarService {
  const AvatarService();

  Future<String?> pickAndEncodeAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1000,
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) return null;
    return base64Encode(bytes);
  }
}
