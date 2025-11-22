import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/platform_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PlatformWrapper.initializePlatform();

  runApp(const CharacterBookApp());
}
