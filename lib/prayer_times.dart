import 'package:flutter/material.dart';
import 'widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrayerTime extends StatefulWidget {
  PrayerTime({Key? key}) : super(key: key);

  @override
  _PrayerTimeState createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  late String apiUrl =
      "https://api.aladhan.com/v1/timingsByAddress?address=Tashkent,%20Uzbekistan";
  late String fajr = '';
  late String sunrise = '';
  late String dhuhr = '';
  late String asr = '';
  late String maghrib = '';
  late String isha = '';

  void initState() {
    super.initState();
    fetchVaqtlar();
  }

  ///////////////////////////// fetching prayer times //////////////////////////
  static String? _currentAddress;
  static Position? _currentPosition;
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
    setState(() {
      if (_currentPosition != null) {
        apiUrl =
            "https://api.aladhan.com/v1/timings?latitude=${_currentPosition?.latitude}&longitude=${_currentPosition?.longitude}&method=1";
      }
    });
    print(apiUrl);
  }

  fetchVaqtlar() async {
    await _getCurrentPosition();
    var response = await http.get(Uri.parse(apiUrl));
    setState(() {
      fajr = json.decode(response.body)['data']['timings']['Fajr'];
      sunrise = json.decode(response.body)['data']['timings']['Sunrise'];
      dhuhr = json.decode(response.body)['data']['timings']['Dhuhr'];
      asr = json.decode(response.body)['data']['timings']['Asr'];
      maghrib = json.decode(response.body)['data']['timings']['Maghrib'];
      isha = json.decode(response.body)['data']['timings']['Isha'];
    });
  }
  /////////////////////////// fetching prayer times end ////////////////////////

  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>[
      fajr,
      sunrise,
      dhuhr,
      asr,
      maghrib,
      isha
    ];
    final List<String> entryNames = <String>[
      "Bomdod",
      "Quyosh",
      "Peshin",
      "Asr",
      "Shom",
      "Xufton"
    ];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Row(
            children: [
              const Text(
                'Namoz vaqtlari',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        drawer: DrawerWidget(),
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entryNames[index] + ": "),
                  Text(entries[index])
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ));
  }
}
