import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: ServerApp()));

class ServerApp extends StatefulWidget {
  @override
  _ServerAppState createState() => _ServerAppState();
}

class _ServerAppState extends State<ServerApp> {
  String _status = 'Server not started';
  List<String> messages = [];
  ServerSocket? server;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    server!.listen(handleClient,
      onError: (e) {
        setState(() {
          messages.add("Server error: $e");
        });
      },
      onDone: () {
        setState(() {
          messages.add("Server has been closed.");
        });
      });
  }

  void handleClient(Socket client) {
    setState(() {
      messages.add('Connection from ${client.remoteAddress.address}:${client.remotePort}');
    });
    client.listen(
      (data) {
        setState(() {
          messages.add('Data from client: ${String.fromCharCodes(data)}');
        });
      },
      onDone: () {
        setState(() {
          messages.add('Client left');
        });
        client.close();
      },
      onError: (error) {
        setState(() {
          messages.add('Client error: $error');
        });
        client.close();
      },
    );
  }
}
