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
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    try {
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        subject: subject,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Шаринг занял слишком много времени');
        },
      );
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
