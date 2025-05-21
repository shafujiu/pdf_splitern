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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** PdfSpliternPlugin */
class PdfSpliternPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private val coroutineScope = CoroutineScope(Dispatchers.IO)

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
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "split" -> {
                coroutineScope.launch {
                    try {
                        val splitResult = withContext(Dispatchers.IO) {
                            split(call)
                        }
                        withContext(Dispatchers.Main) {
                            result.success(splitResult)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("RENDER_ERROR", "Failed to process PDF file", e.message)
                        }
                    }
                }
            }
            "splitToMerge" -> {
                coroutineScope.launch {
                    try {
                        val mergeResult = withContext(Dispatchers.IO) {
                            splitToMerge(call)
                        }
                        withContext(Dispatchers.Main) {
                            result.success(mergeResult)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("RENDER_ERROR", "Failed to process PDF file", e.message)
                        }
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private suspend fun split(call: MethodCall): Any {
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
                
                // 在主线程中发送进度更新
                withContext(Dispatchers.Main) {
                    channel.invokeMethod("onProgress", mapOf(
                        "current" to i + 1,
                        "total" to pageCount
                    ))
                }
            }

            return mapOf(
                "pageCount" to pageCount,
                "pagePaths" to pagePaths
            )
        } finally {
            document.close()
        }
    }

    private suspend fun splitToMerge(call: MethodCall): Any {
        val args = call.arguments as Map<String, Any>
        val filePath = args["filePath"] as String
        val outpath = args["outpath"] as String
        val pageNumbers = args["pageNumbers"] as List<Int>

        val sourceDocument = PDDocument.load(File(filePath))
        val mergedDocument = PDDocument()

        try {
            pageNumbers.reversed().forEachIndexed { index, pageNumber ->
                val page = sourceDocument.getPage(pageNumber)
                mergedDocument.addPage(page)
                
                // 在主线程中发送进度更新
                withContext(Dispatchers.Main) {
                    channel.invokeMethod("onProgress", mapOf(
                        "current" to index + 1,
                        "total" to pageNumbers.size
                    ))
                }
            }

            mergedDocument.save(File(outpath))
            return mapOf("outpath" to outpath)
        } finally {
            sourceDocument.close()
            mergedDocument.close()
        }
    }
}
