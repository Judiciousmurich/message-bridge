package com.actserv.message_bridge

import android.Manifest
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "message_bridge/automation")
            .setMethodCallHandler { call, result ->
                val store = ForwardingStore(this)
                try {
                    when (call.method) {
                        "status" -> {
                            val config = store.config()
                            result.success(mapOf(
                                "enabled" to store.enabled,
                                "permission" to hasSmsPermission(),
                                "account" to config.optString("account"),
                                "from" to config.optString("from"),
                                "to" to config.optString("to"),
                                "sender" to config.optString("sender"),
                                "hasToken" to config.optString("token").isNotEmpty(),
                                "status" to store.status
                            ))
                        }
                        "save" -> {
                            check(!store.enabled) { "Pause forwarding before changing settings." }
                            val input = JSONObject(call.arguments as Map<*, *>)
                            if (input.optString("token").isEmpty()) {
                                input.put("token", store.config().optString("token"))
                            }
                            require(Regex("AC[a-fA-F0-9]{32}").matches(input.optString("account"))) { "Enter a valid Twilio Account SID." }
                            require(input.optString("token").isNotBlank()) { "Enter the Twilio auth token." }
                            for (key in listOf("from", "to")) {
                                require(Regex("\\+[1-9]\\d{6,14}").matches(input.optString(key))) { "Use international numbers, for example +254712345678." }
                            }
                            store.saveConfig(input)
                            result.success(null)
                        }
                        "enable" -> {
                            require(store.config().optString("token").isNotEmpty()) { "Save your connection first." }
                            if (hasSmsPermission()) {
                                store.enabled = true
                                result.success(true)
                            } else if (pending == null) {
                                pending = result
                                requestPermissions(arrayOf(Manifest.permission.RECEIVE_SMS), 401)
                            } else {
                                result.error("busy", "An SMS permission request is already open.", null)
                            }
                        }
                        "disable" -> {
                            store.enabled = false
                            androidx.work.WorkManager.getInstance(this).cancelAllWorkByTag("sms-forwarding")
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("configuration", error.message ?: "Could not update forwarding.", null)
                }
            }
    }

    private fun hasSmsPermission() = checkSelfPermission(Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED

    override fun onRequestPermissionsResult(code: Int, permissions: Array<out String>, grants: IntArray) {
        super.onRequestPermissionsResult(code, permissions, grants)
        if (code == 401) {
            val granted = grants.firstOrNull() == PackageManager.PERMISSION_GRANTED
            ForwardingStore(this).enabled = granted
            pending?.success(granted)
            pending = null
        }
    }

    override fun onDestroy() {
        pending?.success(false)
        pending = null
        super.onDestroy()
    }
}
