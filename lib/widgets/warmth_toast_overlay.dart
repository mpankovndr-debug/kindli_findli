import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/warmth_message_service.dart';
import 'warmth_toast.dart';

class WarmthToastOverlay {
  static OverlayEntry? _current;

  /// Call this when the user taps "Not today".
  static Future<void> show(BuildContext context) async {
    // Don't stack — if one is already showing, skip silently
    if (_current != null) return;

    final l10n = AppLocalizations.of(context);
    final message = await WarmthMessageService.getNext(l10n);
    if (!context.mounted) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _current = OverlayEntry(
      builder: (_) => WarmthToast(
        message: message,
        onDismissed: _remove,
      ),
    );

    overlay.insert(_current!);
  }

  static void _remove() {
    _current?.remove();
    _current = null;
  }
}