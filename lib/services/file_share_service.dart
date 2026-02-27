import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileShareService {
  static Future<void> shareFile(
    Uint8List bytes,
    String fileName, {
    String? text,
    String? subject,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');

    try {
      await file.writeAsBytes(bytes);

      if (!await file.exists()) {
        throw Exception('File was not created');
      }

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: text,
        subject: subject,
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('Sharing timed out'),
      );

      await Future.delayed(const Duration(seconds: 3));
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
