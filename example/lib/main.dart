import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_splitern/pdf_splitern.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _pdfSpliternPlugin = PdfSplitern();

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _pdfSpliternPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Column(
          children: [
            Text('Running on: $_platformVersion\n'),

            ElevatedButton(
              onPressed: () {
                _split();
              },
              child: Text('Split'),
            ),

            ElevatedButton(
              onPressed: () {
                _splitToMerge();
              },
              child: Text('Split to Merge'),
            ),
            
          ],
        )),
      ),
    );
  }

  Future<void> _split() async {
    final outfileDirectory = await FilePicker.platform.getDirectoryPath();
    print(outfileDirectory);

    String filePath = await _assetsfileToAppDirectory('assets/files/pdftestfile.pdf');
    PdfSpliternArgs args = PdfSpliternArgs(filePath, outfileDirectory!);
    PdfSpliternResult result = await PdfSplitern.split(args);
    print(result);
    // await _pdfSpliternPlugin.split(filePath: 'assets/files/test.pdf', outDirectory: 'assets/files/output', outFileNamePrefix: 'test');
  }



  Future<void> _splitToMerge() async {

    final fileDirectory = await FilePicker.platform.getDirectoryPath();
    print(fileDirectory);
    
    String filePath = await _assetsfileToAppDirectory('assets/files/pdftestfile.pdf');
    // 4. 现在 newFile 就是一个真实的文件，可以用 File 相关 API 处理
    //String outPath = '${directory.path}/test_out.pdf';
    String outPath = '$fileDirectory/test_out.pdf';

    String? result = await PdfSplitern.splitToMerge(
      filePath: filePath,
      outpath: outPath,
      pageNumbers: [1, 2],
    );
    print(result);
  }

  Future<String> _assetsfileToAppDirectory(String assetsFilePath) async {
    // 1. 读取 assets 文件内容
    ByteData data = await rootBundle.load('assets/files/pdftestfile.pdf');

    // 2. 获取沙盒目录, 这个是不需要权限就能写的目录
    Directory directory = await getApplicationCacheDirectory();
    String newPath = '${directory.path}/pdfinput.pdf';

    // 3. 写入沙盒目录
    File newFile = File(newPath);
    await newFile.writeAsBytes(data.buffer.asUint8List());
    return newFile.path;
  }
}
