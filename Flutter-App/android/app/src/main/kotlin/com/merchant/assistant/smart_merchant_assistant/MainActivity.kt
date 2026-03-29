package com.merchant.assistant.smart_merchant_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.merchant.assistant/notifications"
    private var eventSink: EventChannel.EventSink? = null

    private val paymentReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == "com.merchant.assistant.ACTION_UPI_PAYMENT") {
                val packageName = intent.getStringExtra("packageName") ?: ""
                val title = intent.getStringExtra("title") ?: ""
                val text = intent.getStringExtra("text") ?: ""

                val map = mapOf(
                    "packageName" to packageName,
                    "title" to title,
                    "text" to text
                )
                eventSink?.success(map)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    val filter = IntentFilter("com.merchant.assistant.ACTION_UPI_PAYMENT")
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(paymentReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                    } else {
                        registerReceiver(paymentReceiver, filter)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    unregisterReceiver(paymentReceiver)
                }
            }
        )
    }
}
