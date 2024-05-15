import 'dart:io'; // nista ovo copy paste za server client text app
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: ClientApp()));

class ClientApp extends StatefulWidget {
  @override
  _ClientAppState createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  Socket? socket;
  
  void connectToServer() async {
    bool isConnected = false;
    const List<String> ipAddresses = ['192.168.0.3', '192.168.0.4', '192.168.0.5'];

    for (String ip in ipAddresses) {
      try {
        socket = await Socket.connect(ip, 3000, timeout: Duration(seconds: 5));
        setState(() {
          messages.add('Connected to: ${socket!.remoteAddress.address}:${socket!.port}');
        });
        isConnected = true;
        break;  // Exit the loop on successful connection
      } catch (e) {
        setState(() {
          messages.add('Failed to connect to $ip: $e');
        });
      }
    }
    if (!isConnected) {
      setState(() {
        messages.add('Failed to connect to any server');
      });
    }
    socket!.listen(
      (List<int> data) {
        setState(() {
          messages.add(new String.fromCharCodes(data));
        });
      },
      onDone: () {
        setState(() {
          messages.add('Disconnected from Server');
          socket!.close();
        });
      },
      onError: (error) {
        setState(() {
          messages.add('Error: $error');
          socket!.close();
        });
      },
    );
  }
  void sendMessage(String message) {
    socket?.add(message.codeUnits);
    socket?.flush();
    setState(() {
      messages.add('Client Send: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Client Status')),
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
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              sendMessage(_controller.text);
              _controller.clear();}, // Add logic for Send Message
            tooltip: 'Send Message',
            child: Icon(Icons.send),
          ),
          SizedBox(height: 10),  // Space between buttons
          FloatingActionButton(
            onPressed: connectToServer,
            tooltip: 'Connect to Server',
            child: Icon(Icons.link),
          ),
        ],
      ),
    );
  }
}


