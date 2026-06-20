import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks a single image from the gallery and returns a [File] in the
/// app's cache directory.
///
/// Uses FileType.custom (not FileType.image) to bypass file_picker's
/// Android compression step — FileType.image triggers compressImage()
/// which calls createTempFile() on external storage and crashes on
/// Android 10+. FileType.custom skips that code path entirely.
/// withData:true reads bytes directly from the content URI so no
/// external-storage write is needed by the plugin either.
Future<File?> pickImageToCache() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'],
    allowMultiple: false,
    withData: true,
    withReadStream: false,
  );

  if (result == null || result.files.isEmpty) return null;

  final picked = result.files.single;
  if (picked.bytes == null) return null;

  // Write bytes to app cache — this directory is always writable.
  final cacheDir = await getTemporaryDirectory();
  final fileName = picked.name.isNotEmpty
      ? picked.name
      : 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final file = File('${cacheDir.path}/$fileName');
  await file.writeAsBytes(picked.bytes!, flush: true);
  return file;
}
