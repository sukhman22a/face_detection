
import 'package:camera/camera.dart';
import 'package:face_recogination/cammeraa/example.dart';
import 'package:flutter/material.dart';

class Loggin extends StatelessWidget {
  final CameraDescription camera;
  const Loggin({super.key, required this.camera});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Face Login",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded)),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                          image: const DecorationImage(
                              image: NetworkImage(
                                "https://dimg.dreamflow.cloud/v1/image/person%20face%20looking%20at%20camera%20for%20biometric%20scan",
                              ),
                              fit: BoxFit.fill,
                              opacity: 0.8),
                          border:
                              Border.all(width: 1, color: const Color(0xffffffff)),
                          borderRadius: const BorderRadius.all(Radius.circular(10)))),
                  FilledButton(
                    onPressed: () {
                       Map<String,String> userInfo = {
                        "name":"",
                        "email":"",
                        "phoneNo":"",
                                  };
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TakePicture(camera: camera,userInfo: userInfo,isRegister: false,)));
                    },
                    style: FilledButton.styleFrom(fixedSize: const Size(200, 40)),
                    child: const Text("click it"),
                  )
                ])));
  }
}
