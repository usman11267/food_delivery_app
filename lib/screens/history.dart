import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/bottomNavBar.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      appBar: AppBar(
        toolbarHeight: 70.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the home screen
            Navigator.pop(context); // Pop the current route from the stack
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "History",
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Colors.black.withOpacity(0.9)),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage("lib/assets/history.png")),
            SizedBox(
              height: 15,
            ),
            Text(
              "No history yet",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 220,
              child: Text(
                " Hit the orange button down below to Create an order",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
