
import 'package:flutter/services.dart';

import 'pdf_splitern_platform_interface.dart';

class PdfSpliternArgs {
  /// File path of the pdf to split
  final String filePath;

  /// Target directory to put files
  final String outDirectory;

  /// Prefix for each pdf page file, default value is 'page_'
  final String outFilePrefix;

  PdfSpliternArgs(this.filePath, this.outDirectory,
      {this.outFilePrefix = "page_"});

  Map get toMap => {
        "filePath": filePath,
        "outDirectory": outDirectory,
        "outFileNamePrefix": outFilePrefix,
      };
}


class PdfSpliternResult {
  int? pageCount;
  late List<String> pagePaths;

  PdfSpliternResult(Map result)
      : assert(result.containsKey("pageCount") &&
            result.containsKey("pagePaths") &&
            result["pagePaths"] is List) {
    pageCount = result["pageCount"];
    pagePaths = <String>[];
    for (var path in (result["pagePaths"] as List)) {
      if (path is String) pagePaths.add(path);
    }
  }
}

class PdfSplitern {
  static final MethodChannel _channel = const MethodChannel('pdf_splitern');

  Future<String?> getPlatformVersion() {
    return PdfSpliternPlatform.instance.getPlatformVersion();
  }


  static Future<PdfSpliternResult> split(PdfSpliternArgs args) async {
    // TODO verify args keys
    return _split(args);
  }

  /// Splits PDF file [value] and returns the page count.
  static Future<PdfSpliternResult> _split(PdfSpliternArgs args) async {
    Map<dynamic, dynamic> result =
        await (_channel.invokeMethod('split', args.toMap));
    return PdfSpliternResult(result);
  }

  static Future<String?> splitToMerge({required String filePath, required String outpath, required List<int> pageNumbers}) async {
    return _splitToMerge(filePath, outpath, pageNumbers);
  }

  // 选择指定页码的pdf文件，合并成一个pdf文件
  static Future<String?> _splitToMerge(String filePath, String outpath, List<int> pageNumbers) async {
    Map<dynamic, dynamic> result =
        await (_channel.invokeMethod('splitToMerge', {
          "filePath": filePath,
          "outpath": outpath,
          "pageNumbers": pageNumbers
        }));
    if (result["outpath"] is String) {
      return result["outpath"];
    }
    return null;
  }
}
