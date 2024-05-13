import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeCodeIntegration extends StatefulWidget {
  @override
  _NativeCodeIntegrationState createState() => _NativeCodeIntegrationState();
}

class _NativeCodeIntegrationState extends State<NativeCodeIntegration> {
  static const platform = MethodChannel('com.example.app/native');

  Future<void> callNativeMethod() async {
    try {
      final String result = await platform.invokeMethod('methodName');
      print('Result from native code: $result');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Native Code Integration'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: callNativeMethod,
          child: Text('Call Native Method'),
        ),
      ),
    );
  }
}