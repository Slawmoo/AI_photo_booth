import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // add this import to handle file paths
import 'package:external_path/external_path.dart';

void main() => runApp(MaterialApp(home: ServerApp()));

class ServerApp extends StatefulWidget {
  @override
  _ServerAppState createState() => _ServerAppState();
}

class _ServerAppState extends State<ServerApp> {
  String _status = 'Server not started';
  List<String> messages = [];
  ServerSocket? server;

//snackBar popUps for messages
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>(); //example SNACKBAR/PRsINT: showSnackbar(context,'text');

  void showSnackbar(BuildContext context, String message) {
  var snackbar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  //endOf snackBars
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // for snackBar
      appBar: AppBar(title: Text('Server Status')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(_status),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startOrRestartServer,
        tooltip: 'Start/Restart Server',
        child: Icon(Icons.refresh),
      ),
    );
  }

  void startOrRestartServer() async {
    if (server != null) {
      await server!.close();
      setState(() {
        messages.add("Server has been stopped.");
      });
    }
    await startServer();
  }

  Future<void> startServer() async {
    server = await ServerSocket.bind('192.168.0.3', 3000);
    setState(() {
      _status = 'Server running on IP : ${server!.address.address} and Port : ${server!.port}';
      messages.add(_status);
    });
    if (server != null) {
    final ServerSocket nonNullableServer = server!;
      await for (var client in nonNullableServer) {
        handleClient(client);
      }
    } else {
      showSnackbar(context,'Failed to start server: ServerSocket is null');
    }
  }

  void handleClient(Socket client) {
    setState(() {
      messages.add('Connection from ${client.remoteAddress.address}:${client.remotePort}');
    });
    List<int> buffer = [];
    client.listen(
      (List<int> data) {
        buffer.addAll(data); // Accumulate data into the buffer
      },
      onDone: () async {
        await saveImage(buffer);
        buffer.clear(); // Clear buffer after saving the image
        client.close();
        setState(() {
          messages.add('Image received and saved');
        });
      },
      onError: (error) {
        setState(() {
          messages.add('Error on receiving data: $error');
        });
        buffer.clear();
        client.close();
      },
    );
  }

  Future<void> saveImage(List<int> buffer) async {
    try {
      final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '$downloadPath/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(buffer);
      
      setState(() {
        messages.add('Image saved to $filePath');
      });
    } catch (e) {
      setState(() {
        messages.add('Failed to save image: $e');
      });
    }
  }
}
//img.setPixelRgba(x, y, color[0], color[1], color[2],0);
//var img = imglib.Image(width: image.width,height: image.height);