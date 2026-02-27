import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareCard(GlobalKey repaintKey, {required Rect sharePositionOrigin}) async {
    // 1. Capture the RepaintBoundary at 3x pixel ratio for crisp 1080x1920 output
    final boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 2. Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/intended_share_card.png');
    await file.writeAsBytes(pngBytes);

    // 3. Share via share_plus
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'My week on Intended',
      sharePositionOrigin: sharePositionOrigin,
    );

    // 4. Clean up temp file
    if (await file.exists()) {
      await file.delete();
    }
  }
}
