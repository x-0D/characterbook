import 'dart:async';
import 'package:characterbook/handlers/desktop_file_handler.dart';
import 'package:characterbook/interfaces/file_handler_interface.dart';
import 'package:flutter/foundation.dart';
//import 'web_file_handler.dart' if (dart.library.io) 'desktop_file_handler.dart';

class FileHandler {
  static FileHandlerInterface? _instance;

  static FileHandlerInterface get _handler {
    _instance ??= _createHandler();
    return _instance!;
  }

  static FileHandlerInterface _createHandler() {
    //if (kIsWeb) {
      //return WebFileHandler();
    //} else {
      return DesktopFileHandler();
    //}
  }

  static Stream<Map<String, dynamic>> get onFileOpened => _handler.onFileOpened;

  static Future<Map<String, dynamic>?> getOpenedFile() =>
      _handler.getOpenedFile();

  static Future<bool> initialize() async {
    try {
      return await _handler.initialize();
    } catch (e) {
      debugPrint('FileHandler initialization error: $e');
      return false;
    }
  }
}
