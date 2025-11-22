import 'dart:async';

abstract class FileHandlerInterface {
  Stream<Map<String, dynamic>> get onFileOpened;
  Future<Map<String, dynamic>?> getOpenedFile();
  Future<bool> initialize();
}
