package com.shopscraper.shop_scraper_app

import android.accounts.AccountManager
import android.app.Activity
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "lootify/google_accounts"
        private const val REQUEST_CODE_PICK_ACCOUNT = 9001
    }

    private var pendingAccountResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickGoogleAccount" -> {
                    if (pendingAccountResult != null) {
                        result.error("ALREADY_ACTIVE", "Account picker is already open", null)
                        return@setMethodCallHandler
                    }
                    pendingAccountResult = result
                    try {
                        val intent: Intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            AccountManager.newChooseAccountIntent(
                                null,
                                null,
                                arrayOf("com.google"),
                                null,
                                null,
                                null,
                                null
                            )
                        } else {
                            @Suppress("DEPRECATION")
                            AccountManager.newChooseAccountIntent(
                                null,
                                null,
                                arrayOf("com.google"),
                                true,
                                null,
                                null,
                                null,
                                null
                            )
                        }
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, REQUEST_CODE_PICK_ACCOUNT)
                    } catch (e: Exception) {
                        pendingAccountResult = null
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_PICK_ACCOUNT) {
            val res = pendingAccountResult
            pendingAccountResult = null
            if (resultCode == Activity.RESULT_OK && data != null) {
                val accountName = data.getStringExtra(AccountManager.KEY_ACCOUNT_NAME)
                res?.success(accountName)
            } else {
                res?.success(null)
            }
        }
    }
}
