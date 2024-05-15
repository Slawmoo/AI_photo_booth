import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Stream Display',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoStreamDisplay(),
    );
  }
}

class VideoStreamDisplay extends StatefulWidget {
  @override
  _VideoStreamDisplayState createState() => _VideoStreamDisplayState();
}

class _VideoStreamDisplayState extends State<VideoStreamDisplay> {
  ServerSocket? server;
  List<Image> frameList = [];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Run tests after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      testServerInitialization(context, this);
      testClientConnection(context, this, "192.168.0.3", 3000);
      testDataReception(context, this, "192.168.0.3", 3000);
    });
  }

  Future<void> startServer() async {
    try {
      server = await ServerSocket.bind("192.168.0.3", 3000);
      showSnackbar(context, 'Server started on ${server!.address.address}:${server!.port}');
      server!.listen(handleClient);
    } catch (e) {
      showSnackbar(context, 'Failed to start server: $e');
    }
  }

  void handleClient(Socket client) {
    showSnackbar(context, 'Client connected: ${client.remoteAddress.address}:${client.remotePort}');
    client.listen(
      (List<int> data) {
        updateFrame(data);
      },
      onError: (error) {
        showSnackbar(context, 'Error from client: $error');
      },
      onDone: () {
        showSnackbar(context, 'Client disconnected');
        client.close();
      },
    );
  }

  void updateFrame(List<int> imgBytes) {
    setState(() {
      frameList.add(Image.memory(Uint8List.fromList(imgBytes)));
    });
  }

  void showSnackbar(BuildContext context, String message) {
    var snackbar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Live Video Stream"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: frameList.map((image) {
            return Container(
              height: 300,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
              ),
              child: image,
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    server?.close();
    super.dispose();
  }
}

void testServerInitialization(BuildContext context, _VideoStreamDisplayState serverState) async {
  await serverState.startServer();
  final message = serverState.server != null ? "Server initialization test passed." : "Server initialization failed.";
  showSnackbar(context, message);
}

void testClientConnection(BuildContext context, _VideoStreamDisplayState serverState, String ip, int port) async {
  await serverState.startServer();
  final client = await Socket.connect(ip, port);
  final message = client != null ? "Client connection handling test passed." : "Client connection to server failed.";
  showSnackbar(context, message);
}

void testDataReception(BuildContext context, _VideoStreamDisplayState serverState, String ip, int port) async {
  await serverState.startServer();
  final client = await Socket.connect(ip, port);

  client.add([/* sample data */]);
  client.flush();
  client.listen((data) {
    final message = data.isNotEmpty ? "Data reception test passed." : "Data reception failed.";
    showSnackbar(context, message);
  });
}

void showSnackbar(BuildContext context, String message) {
  var snackbar = SnackBar(content: Text(message), duration: Duration(seconds: 4));
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
