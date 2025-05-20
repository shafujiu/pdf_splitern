import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pdf_splitern_method_channel.dart';

abstract class PdfSpliternPlatform extends PlatformInterface {
  /// Constructs a PdfSpliternPlatform.
  PdfSpliternPlatform() : super(token: _token);

  static final Object _token = Object();

  static PdfSpliternPlatform _instance = MethodChannelPdfSplitern();

  /// The default instance of [PdfSpliternPlatform] to use.
  ///
  /// Defaults to [MethodChannelPdfSplitern].
  static PdfSpliternPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PdfSpliternPlatform] when
  /// they register themselves.
  static set instance(PdfSpliternPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
