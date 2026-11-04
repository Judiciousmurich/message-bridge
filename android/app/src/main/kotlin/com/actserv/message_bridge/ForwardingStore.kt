package com.actserv.message_bridge

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import org.json.JSONObject
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** The token and queued SMS contents are encrypted using a device-bound key. */
class ForwardingStore(context: Context) {
    private val prefs = context.getSharedPreferences("forwarding", Context.MODE_PRIVATE)

    var enabled: Boolean
        get() = prefs.getBoolean("enabled", false)
        set(value) {
            check(prefs.edit().putBoolean("enabled", value)
                .putString("session", java.util.UUID.randomUUID().toString()).commit())
        }

    val session: String get() = prefs.getString("session", "")!!

    var status: String
        get() = prefs.getString("status", "No SMS processed yet.")!!
        set(value) { prefs.edit().putString("status", value).commit() }

    fun config(): JSONObject {
        val stored = prefs.getString("config", null) ?: return JSONObject()
        return JSONObject(decrypt(stored))
    }

    fun saveConfig(config: JSONObject) {
        check(prefs.edit().putString("config", encrypt(config.toString())).commit())
    }

    fun state(id: String) = prefs.getString("event_$id", "")!!
    fun setState(id: String, state: String) {
        check(prefs.edit().putString("event_$id", state).commit())
    }

    private fun key(): SecretKey {
        synchronized(ForwardingStore::class.java) {
            val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            (store.getKey("message_bridge", null) as? SecretKey)?.let { return it }
            return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore").apply {
                init(KeyGenParameterSpec.Builder("message_bridge", KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
            }.generateKey()
        }
    }

    fun encrypt(value: String): String {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key())
        return Base64.encodeToString(cipher.iv + cipher.doFinal(value.toByteArray(Charsets.UTF_8)), Base64.NO_WRAP)
    }

    fun decrypt(value: String): String {
        val data = Base64.decode(value, Base64.NO_WRAP)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, data.copyOfRange(0, 12)))
        return String(cipher.doFinal(data.copyOfRange(12, data.size)), Charsets.UTF_8)
    }
}
