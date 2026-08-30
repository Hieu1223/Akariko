package com.example.arisu_browser

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.atilika.kuromoji.ipadic.Tokenizer
import com.atilika.kuromoji.ipadic.Token as KuromojiToken

/// Hosts the `yomu/tokenizer` MethodChannel (phase 4).
///
/// The Kuromoji ipadic dictionary is loaded once, here in [configureFlutterEngine],
/// so lookups in [tokenize] are cheap. Tokenization itself runs on a background
/// thread and posts the result back to the main looper, keeping the UI thread free
/// even for longer pasted sentences.
class MainActivity : FlutterActivity() {
    private val channel = "yomu/tokenizer"
    private lateinit var tokenizer: Tokenizer

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tokenizer = Tokenizer.Builder().build()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "tokenize" -> {
                        val text = call.argument<String>("text") ?: ""
                        tokenize(text, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun tokenize(text: String, result: MethodChannel.Result) {
        Thread {
            try {
                val tokens: List<Map<String, String>> =
                    tokenizer.tokenize(text).map { t: KuromojiToken ->
                        mapOf(
                            "surface" to t.surface,
                            "reading" to t.reading,
                            "baseForm" to t.baseForm,
                            "partOfSpeech" to t.partOfSpeechLevel1,
                        )
                    }
                Handler(Looper.getMainLooper()).post { result.success(tokens) }
            } catch (e: Exception) {
                Handler(Looper.getMainLooper())
                    .post { result.error("TOKENIZE_FAILED", e.message, null) }
            }
        }.start()
    }
}
