import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'suralar.dart';
import 'prayer_times.dart';
import 'contact.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Quran app',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('Suralar'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Suralar()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.watch_later),
            title: Text('Namoz vaqtlari'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrayerTime()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Contact'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Contact()),
              );
            },
          ),
        ],
      ),
    );
  }
}
