import 'package:flutter/services.dart';

class MenuChannel {
  static const MethodChannel _channel = MethodChannel('characterbook/menu');

  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'openSettings':
      
        break;
      case 'newCharacter':

        break;
      case 'openFile':

        break;
    }
  }
}
