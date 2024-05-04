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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 237, 17, 17),Color.fromARGB(255, 207, 101, 101), Color.fromARGB(255, 86, 9, 100)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'AI Photo Booth',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 60),
            Center(
              child: SizedBox(
                width: 450,
                child: ActionButton(title: 'CONNECT WITH MOBILE PHONE'),
              ),
            ),
            SizedBox(height: 10),
            const Text(
              'PHONE CONNECTED',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            const Text(
              'MAKE MEMORIES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'AND SEE THEM IN REALITY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 350,
                child: ActionButton(title: 'START PHOTO SESSION'),
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
    return SizedBox(
  width: MediaQuery.of(context).size.width * 0.3,
  child: ElevatedButton(
    onPressed: () {
      // Define the action when the button is pressed
    },
    style: ElevatedButton.styleFrom(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
    ),
  ),
);
  }
}

