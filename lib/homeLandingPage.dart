import 'package:flutter/material.dart';

void main() => runApp(AIPhotoBoothApp());

class AIPhotoBoothApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Photo Booth',
      home: AIPhotoBoothHomePage(),
    );
  }
}

class AIPhotoBoothHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink, Colors.purple],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'AI Photo Booth',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ActionButton(title: 'CONNECT WITH MOBILE PHONE'),
            SizedBox(height: 10),
            Text(
              'PHONE CONNECTED',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'MAKE MEMORIES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ActionButton(title: 'START PHOTO SESSION'),
            SizedBox(height: 20),
            Text(
              'AND SEE THEM IN REALITY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;

  ActionButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      child:ElevatedButton(
      onPressed: () {
        // Define the action when the button is pressed
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent, // No shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.white), // Border color and width
        ),
      ),
      ),
    );
  }
}
