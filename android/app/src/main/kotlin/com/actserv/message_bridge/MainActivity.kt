package com.actserv.message_bridge

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore

class MainActivity : FlutterActivity() {

    private var pendingSharedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        clearRetiredForwardingData()
        captureShareIntent(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureShareIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.actserv.message_bridge/share",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumeSharedText" -> {
                    val text = pendingSharedText
                    pendingSharedText = null
                    result.success(text)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun captureShareIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            pendingSharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        }
    }

    /** Drops the Twilio token and queued SMS left by the removed forwarding feature. */
    private fun clearRetiredForwardingData() {
        getSharedPreferences("forwarding", Context.MODE_PRIVATE).edit().clear().commit()
        try {
            val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            if (store.containsAlias("message_bridge")) {
                store.deleteEntry("message_bridge")
            }
        } catch (_: Exception) {
        }
    }
}