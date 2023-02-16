import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'suralarDetail.dart';
import 'widgets.dart';

void main() {
  runApp(const MaterialApp(
    home: Suralar(),
    debugShowCheckedModeBanner: false,
  ));
}

class Suralar extends StatefulWidget {
  const Suralar({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SuralarState createState() => _SuralarState();
}

class SuralarModel {
  int number;
  String name;
  String englishName;
  String englishNameTranslation;

  SuralarModel(
      {required this.number,
      required this.name,
      required this.englishName,
      required this.englishNameTranslation});

  factory SuralarModel.fromJson(Map<String, dynamic> json) {
    return SuralarModel(
      number: json["number"],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
    );
  }
}

class _SuralarState extends State<Suralar> {
  final String apiUrl = "http://api.alquran.cloud/v1/surah";
  Future<List<SuralarModel>> fetchSuralar() async {
    var response = await http.get(Uri.parse(apiUrl));
    return (json.decode(response.body)['data'] as List)
        .map((e) => SuralarModel.fromJson(e))
        .toList();
  }

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
              'Suralar',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      drawer: DrawerWidget(),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: FutureBuilder<List<SuralarModel>>(
          future: fetchSuralar(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<SuralarModel> suralar = snapshot.data as List<SuralarModel>;
              return ListView.builder(
                itemCount: suralar.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SuralarDetail(suraId: index)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0, bottom: 30.0, left: 15.0, right: 15.0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 6.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                width: 33,
                                height: 33,
                                child: Column(
                                  children: <Widget>[
                                    Text((index + 1).toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    suralar[index].englishName.toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(suralar[index].name.toString()),
                                ],
                              ),
                            ],
                          ),
                        )),
                  );
                },
              );
            }
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Text('error');
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
