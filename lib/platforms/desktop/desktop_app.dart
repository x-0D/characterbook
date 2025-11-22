import 'package:flutter/material.dart';
import 'desktop_title_bar.dart';
import 'package:characterbook/common/home_page.dart';

class DesktopAppFrame extends StatelessWidget {
  const DesktopAppFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          DesktopTitleBar(),
          const Expanded(child: HomePage()),
        ],
      ),
    );
  }
}
