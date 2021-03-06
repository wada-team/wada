import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'package:audioplayers/audioplayers.dart';

FirebaseAuth currUser = FirebaseAuth.instance;
var user = FirebaseAuth.instance.currentUser;
Query query = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('plants');

var roomset = <String>{};

class Watering extends StatefulWidget {
  final String name;

  Watering({this.name});
  @override
  State<StatefulWidget> createState() => _WateringState();
}

class _WateringState extends State<Watering> {

  String today = new DateFormat('EEEE').format(DateTime.now());
  String title = 'Watering';
  bool v = false;

  AudioPlayer audioPlayer = AudioPlayer();

  int getDayIndex() {
    int dayInt;
    switch (today) {
      case "Sunday":    dayInt = 0; break;
      case "Monday":    dayInt = 1; break;
      case "Tuesday":   dayInt = 2; break;
      case "Wednesday": dayInt = 3; break;
      case "Thursday":  dayInt = 4; break;
      case "Friday":    dayInt = 5; break;
      case "Saturday":  dayInt = 6; break;
    }
    return dayInt;
  }

  void getRooms() {
    query
        .get()
        .then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            if (doc['days'][getDayIndex()]) {
              roomset.add(doc['room']);
            }
          })
        });
  }

  /* Function 2: Contains room title and all plants within it */
  Widget buildRoomTile (String room) {
    return new Column (
      children: <Widget>[
        Container (
          padding: const EdgeInsets.only(left: 8, top:8, bottom:8),
          child: Text(
            room,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(width: 2, color: Colors.black12),
                left: BorderSide(width: 2, color: Colors.black12),
                bottom: BorderSide(width: 2, color: Colors.black12)),
          ),
          height: 50,
        ),
        plantTitleAndPlants(room)
      ],
    );
  }

  Widget plantTitleAndPlants(String room) {
    Stream s = query
        .where('room', isEqualTo: room)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: s,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return new ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 8, top:8, bottom:8),
          children:
          snapshot.data.docs.map((DocumentSnapshot document) {
            if (document != null
                && document.data().containsValue(room)
                && document.data()['days'][getDayIndex()] != false) {
              return Row(
                children: [
                  /*Checkbox(
                    value: document.data()['watered'],
                    onChanged: (value) {
                      setState(() {
                        document.data()['watered'] = !document.data()['watered'];
                      });
                    },),*/
                  Expanded(child: Plants.wateringView(document, true)),
                ],
              );
            }
            else {
              return SizedBox( width: 0, height:0);
            }
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getRooms();
    play() async {
      int result = await audioPlayer.play("https://huds.tf/site/xthreads_attach.php/3666_1615030581_f8449030/2311a5ffe515b5a535867a8d1f0869e7/yup.wav");
      if (result == 1) {
        print("success");
      }
    }
    play();
    return MaterialApp(
      title: title,
      home: Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(
            title: Text(
              "Watering for " + today + " "
                  + DateFormat.yMMMMd('en_US').format(DateTime.now()),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView (
            children: <Widget>[
              for (var room in roomset) if (room != null) buildRoomTile(room)
            ],
          )
      ),
    );
  }

  Widget _buildVineView() => Container(
    decoration: BoxDecoration(
      border: Border(
        right: BorderSide(width: 2, color: Colors.black12),
      ),
    ),
  );
}