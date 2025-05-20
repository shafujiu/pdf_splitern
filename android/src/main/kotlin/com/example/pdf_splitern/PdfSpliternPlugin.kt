package com.example.pdf_splitern

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import com.tom_roush.pdfbox.pdmodel.PDDocument
import java.io.IOException

/** PdfSpliternPlugin */
class PdfSpliternPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pdf_splitern")
        channel.setMethodCallHandler(this)
        // 初始化PDFBox
        PDFBoxResourceLoader.init(flutterPluginBinding.applicationContext)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "split") {
            try {
                result.success(split(call))
            } catch (e: Exception) {
                result.error("RENDER_ERROR", "Failed to process PDF file", e.message)
            }
        } else if (call.method == "splitToMerge") {
            try {
                result.success(splitToMerge(call))
            } catch (e: Exception) {
                result.error("RENDER_ERROR", "Failed to process PDF file", e.message)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun split(call: MethodCall): Any {
        val args = call.arguments as Map<String, Any>
        val filePath = args["filePath"] as String
        val outDirectory = args["outDirectory"] as String
        val outFileNamePrefix = args["outFileNamePrefix"] as String

        val document = PDDocument.load(File(filePath))
        val pageCount = document.numberOfPages
        val pagePaths = mutableListOf<String>()

        try {
            for (i in 0 until pageCount) {
                val singlePage = PDDocument()
                singlePage.addPage(document.getPage(i))
                val singlePageFilename = "$outDirectory/$outFileNamePrefix$i.pdf"
                singlePage.save(File(singlePageFilename))
                singlePage.close()
                pagePaths.add(singlePageFilename)
            }

            val splitResult = mapOf(
                "pageCount" to pageCount,
                "pagePaths" to pagePaths
            )
            return splitResult
        } finally {
            document.close()
        }
    }

    private fun splitToMerge(call: MethodCall): Any {
        val args = call.arguments as Map<String, Any>
        val filePath = args["filePath"] as String
        val outpath = args["outpath"] as String
        val pageNumbers = args["pageNumbers"] as List<Int>

        val sourceDocument = PDDocument.load(File(filePath))
        val mergedDocument = PDDocument()

        try {
            // 按照iOS实现，我们需要反向遍历页码
            pageNumbers.reversed().forEach { pageNumber ->
                val page = sourceDocument.getPage(pageNumber)
                mergedDocument.addPage(page)
            }

            mergedDocument.save(File(outpath))
            return mapOf("outpath" to outpath)
        } finally {
            sourceDocument.close()
            mergedDocument.close()
        }
    }
}
