package com.actserv.message_bridge

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import java.security.KeyStore

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        clearRetiredForwardingData()
        super.onCreate(savedInstanceState)
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