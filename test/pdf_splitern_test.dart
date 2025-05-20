import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_splitern/pdf_splitern.dart';
import 'package:pdf_splitern/pdf_splitern_platform_interface.dart';
import 'package:pdf_splitern/pdf_splitern_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPdfSpliternPlatform
    with MockPlatformInterfaceMixin
    implements PdfSpliternPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PdfSpliternPlatform initialPlatform = PdfSpliternPlatform.instance;

  test('$MethodChannelPdfSplitern is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPdfSplitern>());
  });

  test('getPlatformVersion', () async {
    PdfSplitern pdfSpliternPlugin = PdfSplitern();
    MockPdfSpliternPlatform fakePlatform = MockPdfSpliternPlatform();
    PdfSpliternPlatform.instance = fakePlatform;

    expect(await pdfSpliternPlugin.getPlatformVersion(), '42');
  });
}
