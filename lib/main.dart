import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'adapters/custom_field_adapter.dart';
import 'generated/l10n.dart';
import 'models/character_model.dart';
import 'models/note_model.dart';
import 'models/race_model.dart';
import 'models/template_model.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/file_handler.dart';
import 'services/file_handler_wrapper.dart';
import 'ui/pages/home_page.dart';

Future<void> _initializeHive() async {
  await Hive.initFlutter();
  

  Hive
    ..registerAdapter(CharacterAdapter())
    ..registerAdapter(CustomFieldAdapter())
    ..registerAdapter(NoteAdapter())
    ..registerAdapter(RaceAdapter())
    ..registerAdapter(QuestionnaireTemplateAdapter());

  await Future.wait([
    Hive.openBox<Character>('characters'),
    Hive.openBox<Note>('notes'),
    Hive.openBox<Race>('races'),
    Hive.openBox<QuestionnaireTemplate>('templates'),
  ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeHive();
  FileHandler.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CharacterBook',
      locale: localeProvider.locale ?? const Locale('ru'),
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