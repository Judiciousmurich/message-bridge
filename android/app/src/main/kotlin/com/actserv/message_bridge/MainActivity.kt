package com.actserv.message_bridge

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        clearRetiredForwardingData()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "message_bridge/sms")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasSmsPermission())
                    "requestPermission" -> requestSmsPermission(result)
                    "openSettings" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.fromParts("package", packageName, null)
                            )
                        )
                        result.success(null)
                    }
                    "list" -> {
                        try {
                            result.success(listSms())
                        } catch (_: SecurityException) {
                            result.error(
                                "permission",
                                "This phone did not allow Message Bridge to read texts.",
                                null
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
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

    private fun hasSmsPermission() =
        checkSelfPermission(Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (hasSmsPermission()) {
            result.success(true)
            return
        }
        if (pending != null) {
            result.error("busy", "An SMS permission request is already open.", null)
            return
        }
        pending = result
        requestPermissions(arrayOf(Manifest.permission.READ_SMS), 402)
    }

    private fun listSms(): List<Map<String, Any>> {
        if (!hasSmsPermission()) throw SecurityException("SMS permission is required.")
        val messages = mutableListOf<Map<String, Any>>()
        val cursor = contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            arrayOf(
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.TYPE
            ),
            "${Telephony.Sms.TYPE} IN (?, ?)",
            arrayOf(
                Telephony.Sms.MESSAGE_TYPE_INBOX.toString(),
                Telephony.Sms.MESSAGE_TYPE_SENT.toString()
            ),
            "${Telephony.Sms.DATE} DESC"
        ) ?: return messages
        cursor.use {
            val idIndex = it.getColumnIndexOrThrow(Telephony.Sms._ID)
            val addressIndex = it.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
            val bodyIndex = it.getColumnIndexOrThrow(Telephony.Sms.BODY)
            val dateIndex = it.getColumnIndexOrThrow(Telephony.Sms.DATE)
            val typeIndex = it.getColumnIndexOrThrow(Telephony.Sms.TYPE)
            while (it.moveToNext() && messages.size < 200) {
                val type = it.getInt(typeIndex)
                messages.add(
                    mapOf(
                        "id" to it.getLong(idIndex).toString(),
                        "address" to (it.getString(addressIndex) ?: ""),
                        "body" to (it.getString(bodyIndex) ?: ""),
                        "date" to it.getLong(dateIndex),
                        "box" to if (type == Telephony.Sms.MESSAGE_TYPE_SENT) "sent" else "inbox"
                    )
                )
            }
        }
        return messages
    }

    override fun onRequestPermissionsResult(
        code: Int,
        permissions: Array<out String>,
        grants: IntArray
    ) {
        super.onRequestPermissionsResult(code, permissions, grants)
        if (code == 402) {
            pending?.success(grants.firstOrNull() == PackageManager.PERMISSION_GRANTED)
            pending = null
        }
    }

    override fun onDestroy() {
        pending?.success(false)
        pending = null
        super.onDestroy()
    }
}
