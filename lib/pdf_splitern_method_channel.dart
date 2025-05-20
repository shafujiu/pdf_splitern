import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pdf_splitern_platform_interface.dart';

/// An implementation of [PdfSpliternPlatform] that uses method channels.
class MethodChannelPdfSplitern extends PdfSpliternPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pdf_splitern');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
