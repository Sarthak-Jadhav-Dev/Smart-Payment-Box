package com.merchant.assistant.smart_merchant_assistant

import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class UPIPaymentListenerService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        sbn?.let {
            val packageName = it.packageName
            val extras = it.notification.extras
            val title = extras.getCharSequence("android.title")?.toString() ?: ""
            val text = extras.getCharSequence("android.text")?.toString() ?: ""

            Log.d("UPIPaymentListener", "Received notification from: $packageName")
            Log.d("UPIPaymentListener", "Title: $title")
            Log.d("UPIPaymentListener", "Text: $text")

            val intent = Intent("com.merchant.assistant.ACTION_UPI_PAYMENT")
            intent.putExtra("packageName", packageName)
            intent.putExtra("title", title)
            intent.putExtra("text", text)
            intent.setPackage("com.merchant.assistant.smart_merchant_assistant")
            
            sendBroadcast(intent)
            Log.d("UPIPaymentListener", "Broadcast sent to our app")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
}
