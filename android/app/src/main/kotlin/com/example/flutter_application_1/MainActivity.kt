package com.example.flutter_application_1

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "samples.flutter.dev/network"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDevices" -> {
                    val devices = getNetworkDevices()
                    result.success(devices)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getNetworkDevices(): List<String> {
        val devices = mutableListOf<String>()
        val subnet = "192.168.1"  // Adjust the subnet part as needed.
        for (i in 1..254) {
            val ip = "$subnet.$i"
            if (pingHost(ip)) {
                devices.add(ip)
            }
        }
        return devices
    }

    private fun pingHost(ip: String): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("/system/bin/ping -c 1 $ip")
            val input = BufferedReader(InputStreamReader(process.inputStream))
            var inputLine: String?
            var found = false
            while (input.readLine().also { inputLine = it } != null) {
                if (inputLine!!.contains("1 received")) {
                    found = true
                    break
                }
            }
            input.close()
            found
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
