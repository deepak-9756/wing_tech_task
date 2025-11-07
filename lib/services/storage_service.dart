import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  final String _bucketName = 'profile-images';

  /// Upload profile image to Supabase Storage
  Future<String> uploadProfileImage({
    required String uid,
    required XFile imageFile,
  }) async {
    try {
      final file = File(imageFile.path);
      final fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'public/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final imageUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image from Supabase Storage
  Future<void> deleteProfileImage(String uid) async {
    try {
      // Get list of files for this user
      final files = await _supabase.storage
          .from(_bucketName)
          .list(path: 'public');

      // Find and delete files matching this UID
      final userFiles =
          files
              .where((file) => file.name.startsWith(uid))
              .map((file) => 'public/${file.name}')
              .toList();

      if (userFiles.isNotEmpty) {
        await _supabase.storage.from(_bucketName).remove(userFiles);
      }
    } catch (e) {
      // Silently fail - not critical if delete fails
      print('Error deleting image: $e');
    }
  }

  /// Delete image by direct URL
  Future<void> deleteProfileImageByUrl(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find 'public' segment and get path after it
      final publicIndex = pathSegments.indexOf('public');
      if (publicIndex != -1 && publicIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(publicIndex).join('/');
        await _supabase.storage.from(_bucketName).remove([filePath]);
      }
    } catch (e) {
      print('Error deleting image by URL: $e');
    }
  }
}
