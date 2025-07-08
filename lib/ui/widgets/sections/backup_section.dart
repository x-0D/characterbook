import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/backup_buttons_widget.dart';
import 'package:characterbook/ui/widgets/sections/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/services/cloud_backup_service.dart';

class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SettingsSection(
      title: s.backup,
      children: [
        Center(
          child: BackupButtons(cloudBackupService: CloudBackupService()),
        ),
      ],
    );
  }
}