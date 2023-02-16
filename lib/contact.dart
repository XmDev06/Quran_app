import 'package:flutter/material.dart';
import './widgets.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Text(
              'Contact',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          children: <Widget>[Text("Hello world! Contact")],
        ),
      ),
    );
  }
}