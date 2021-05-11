import 'package:flutter/material.dart';
import 'package:image_recognition_app/MainPage.dart';

class SplashScreen extends StatefulWidget {
  static const id = "SplashScreen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future delay() async {
    await new Future.delayed(new Duration(seconds:2), () {
      Navigator.of(context).restorablePushNamedAndRemoveUntil(MainPage.id, (route) => false);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    delay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          child: Image.asset("images/box.jpg", fit: BoxFit.fill),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Loading...",
                style: TextStyle(color: Colors.white, fontSize: 18),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
