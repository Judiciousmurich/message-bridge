package com.actserv.message_bridge

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.util.Base64
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONObject
import java.net.URL
import java.net.URLEncoder
import javax.net.ssl.HttpsURLConnection

class ForwardSmsWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        val store = ForwardingStore(applicationContext)
        val id = inputData.getString("id") ?: return Result.failure()
        if (!store.enabled || inputData.getString("session") != store.session || applicationContext.checkSelfPermission(Manifest.permission.RECEIVE_SMS) != PackageManager.PERMISSION_GRANTED) return Result.success()
        // A previous process may have died after submitting. Never silently send twice.
        if (store.state(id).isNotEmpty()) {
            if (store.state(id) == "sending") store.status = "Previous SMS submission interrupted. Delivery unknown. Not resent."
            return Result.success()
        }
        var connection: HttpsURLConnection? = null
        try {
            val config = store.config()
            val body = store.decrypt(inputData.getString("body") ?: return Result.failure())
            val fields = mapOf("From" to "whatsapp:${config.getString("from")}", "To" to "whatsapp:${config.getString("to")}", "Body" to body)
            val payload = fields.entries.joinToString("&") { (key, value) -> "$key=${URLEncoder.encode(value, "UTF-8")}" }.toByteArray(Charsets.UTF_8)
            connection = URL("https://api.twilio.com/2010-04-01/Accounts/${config.getString("account")}/Messages.json").openConnection() as HttpsURLConnection
            connection.requestMethod = "POST"
            connection.connectTimeout = 15000
            connection.readTimeout = 20000
            connection.instanceFollowRedirects = false
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
            val credentials = "${config.getString("account")}:${config.getString("token")}"
            connection.setRequestProperty("Authorization", "Basic " + Base64.encodeToString(credentials.toByteArray(Charsets.UTF_8), Base64.NO_WRAP))
            if (!store.enabled || inputData.getString("session") != store.session || isStopped) return Result.success()
            store.setState(id, "sending")
            store.status = "Submitting SMS to WhatsApp…"
            connection.outputStream.use { it.write(payload) }
            val code = connection.responseCode
            val response = (if (code in 200..299) connection.inputStream else connection.errorStream)
                ?.bufferedReader()?.use { it.readText() }.orEmpty()
            val json = try { JSONObject(response) } catch (_: Exception) { JSONObject() }
            if (code in 200..299 && json.optString("sid").isNotEmpty()) {
                store.setState(id, "accepted")
                store.status = "Accepted by Twilio (${json.optString("status", "queued")}). Delivery to WhatsApp is not yet confirmed."
                return Result.success()
            }
            store.setState(id, "failed")
            store.status = when (json.optInt("code")) {
                63016 -> "WhatsApp session expired. Recipient must message your test sender to open a 24-hour session. This SMS was not resent."
                63015 -> "Recipient has not joined your Twilio WhatsApp Sandbox."
                20003 -> "Twilio authentication failed. Check the Account SID and auth token."
                else -> "WhatsApp API rejected SMS (HTTP $code, Twilio code ${json.optInt("code")}). Check Twilio logs."
            }
            return Result.failure()
        } catch (_: Exception) {
            store.status = "SMS delivery could not be confirmed. Check Twilio logs. Not resent to avoid duplicates."
            return Result.failure()
        } finally {
            connection?.disconnect()
        }
    }
}
