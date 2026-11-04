package com.actserv.message_bridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import androidx.work.*
import java.security.MessageDigest

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val store = ForwardingStore(context)
        if (!store.enabled) return
        val session = store.session
        val pending = goAsync()
        Thread {
            try {
                val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (parts.isEmpty()) return@Thread
                val sender = parts.first().originatingAddress.orEmpty()
                val filter = store.config().optString("sender")
                if (filter.isNotEmpty() && sender != filter) return@Thread
                val body = parts.joinToString("") { it.messageBody.orEmpty() }
                if (body.isEmpty()) return@Thread
                // Stable across duplicate delivery, but distinct for separate identical texts.
                val fingerprint = "$sender\n${parts.first().timestampMillis}\n$body"
                val id = MessageDigest.getInstance("SHA-256").digest(fingerprint.toByteArray())
                    .joinToString("") { "%02x".format(it) }
                if (store.state(id).isNotEmpty()) return@Thread
                if (body.length > 1500) {
                    store.status = "SMS too long for this MVP (maximum 1500 characters). Nothing sent."
                    return@Thread
                }
                val request = OneTimeWorkRequestBuilder<ForwardSmsWorker>()
                    .setInputData(workDataOf("id" to id, "body" to store.encrypt(body), "session" to session))
                    .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
                    .addTag("sms-forwarding")
                    .build()
                store.status = "SMS queued. Waiting for internet or Android's scheduler."
                WorkManager.getInstance(context).enqueueUniqueWork("sms-$id", ExistingWorkPolicy.KEEP, request)
                    .result.get(8, java.util.concurrent.TimeUnit.SECONDS)
            } catch (_: Exception) {
                store.status = "Could not queue incoming SMS. Reopen the app and check settings."
            } finally {
                pending.finish()
            }
        }.start()
    }
}
