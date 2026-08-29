import 'package:camera/camera.dart';
import 'package:face_recogination/login/logggin.dart';
import 'package:face_recogination/register/details.dart';

import 'package:flutter/material.dart';

class Register_card extends StatelessWidget {
  final CameraDescription camera;
  const Register_card({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    int num = 0;
    return Container(
        padding: const EdgeInsets.all(10.0),
        height: 150,
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
            elevation: 4, // Card shadow depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                ListTile(
                  onTap: () {
                    num = num + 1;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Details(camera: camera)));
                  },
                  leading: const Icon(Icons.person_add),
                  title: const Text('Register User'),
                  subtitle: const Text("Enroll a new face"),
                  trailing: const Icon(Icons.navigate_next),
                ),
              ]),
            ),
          ),
        ));
  }
}

class Login_Card extends StatelessWidget {
  final CameraDescription camera;
  const Login_Card({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        height: 120,
        child: Center(
          child: Card(
            // margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            elevation: 4, // Card shadow depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login'),
                  subtitle: const Text('Identify User'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Loggin(camera: camera)));
                  },
                ),
              ]),
            ),
          ),
        ));
  }
}
