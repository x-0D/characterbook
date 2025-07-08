import 'package:characterbook/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'models/character_model.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/file_handler.dart';
import 'services/file_handler_wrapper.dart';
import 'ui/pages/home_page.dart';

Future<void> _initializeHive() async {
  await HiveService.initHive();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeHive();
  FileHandler.initialize();

  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const _App(),
    ),
  );
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Hive.box<Character>('characters').flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: true);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CharacterBook',
      locale: localeProvider.locale,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const FileHandlerWrapper(child: HomePage()),
    );
  }
}