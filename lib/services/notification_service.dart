import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  NotificationService(this.messengerKey);

  void showSuccess(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showError(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showBackupSuccess() {
    showSuccess(S.current.local_backup_success);
  }

  void showBackupError(String error) {
    showError('${S.current.local_backup_error}: $error');
  }

  void showRestoreSuccess() {
    showSuccess(S.current.local_restore_success);
  }

  void showRestoreError(String error) {
    showError('${S.current.local_restore_error}: $error');
  }
}
