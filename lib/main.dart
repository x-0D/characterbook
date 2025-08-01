import 'dart:io';

import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:characterbook/services/hive_service.dart';
import 'package:characterbook/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'generated/l10n.dart';
import 'models/character_model.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/file_handler.dart';
import 'services/file_handler_wrapper.dart';
import 'ui/pages/home_page.dart';

Future<void> _initializeHive() async {
  await HiveService.initHive();
  await Future.wait([
    HiveService.getBox<Character>('characters'),
    HiveService.getBox<Note>('notes'),
    HiveService.getBox<Race>('races'),
    HiveService.getBox<QuestionnaireTemplate>('templates'),
    HiveService.getBox<Folder>('folders')
  ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow();
  }
  
  await _initializeHive();
  FileHandler.initialize();

  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final notificationService = NotificationService(scaffoldMessengerKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        Provider<NotificationService>.value(value: notificationService),
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

class _AppState extends State<_App> with WidgetsBindingObserver, WindowListener {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (Platform.isWindows || Platform.isMacOS) {
      windowManager.addListener(this);
      _initWindow();
    }
  }

  Future<void> _initWindow() async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setMinimumSize(const Size(800, 600));
    await windowManager.center();
    await windowManager.show();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isWindows || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Hive.box<Character>('characters').flush();
    }
  }

  bool isMobile() {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDesktopWindowFrame(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          Container(
            height: 36,
            color: theme.colorScheme.surfaceContainerLowest,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 24,
                        height: 24,
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Image.asset(
                          'assets/iconapp.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CharacterBook',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                
                Positioned(
                  right: 0,
                  child: Row(
                    children: [
                      _WindowControlButton(
                        icon: Icons.minimize,
                        onPressed: () => windowManager.minimize(),
                      ),
                      _WindowControlButton(
                        icon: Icons.crop_square,
                        onPressed: () => windowManager.isMaximized()
                            .then((isMaximized) => isMaximized
                                ? windowManager.unmaximize()
                                : windowManager.maximize()),
                      ),
                      _WindowControlButton(
                        icon: Icons.close,
                        onPressed: () => windowManager.close(),
                        isClose: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: const HomePage(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: true);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final notificationService = Provider.of<NotificationService>(context);
    final homePage = isMobile() 
        ? const FileHandlerWrapper(child: HomePage())
        : _buildDesktopWindowFrame(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: notificationService.messengerKey,
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
      home: homePage,
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor = widget.isClose
        ? colorScheme.error.withOpacity(isDark ? 0.12 : 0.08)
        : colorScheme.onPrimaryContainer.withOpacity(isDark ? 0.08 : 0.04);
    Color iconColor = widget.isClose
        ? colorScheme.error
        : colorScheme.onSurface.withOpacity(0.8);

    if (_isHovered) {
      backgroundColor = widget.isClose
          ? colorScheme.error.withOpacity(isDark ? 0.24 : 0.16)
          : colorScheme.onSurface.withOpacity(isDark ? 0.16 : 0.12);
      
      iconColor = widget.isClose
          ? colorScheme.error
          : colorScheme.onSurface;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onPressed,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  widget.icon,
                  key: ValueKey<bool>(_isHovered),
                  size: 16,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}