
import 'package:camera/camera.dart';

import 'package:face_recogination/register/Errorr.dart';
import 'package:face_recogination/register/details.dart';
import 'package:flutter/material.dart';

class Register extends StatelessWidget {
  final CameraDescription camera;
  const Register({super.key, required this.camera});

  // final bool h = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: const [
            Chip(
              backgroundColor: Color(0xff2563eb),
              avatar: Icon(
                Icons.check_rounded,
                color: Color(0xffffffff),
              ),
              label: Text(
                'step 1/2',
                style: TextStyle(color: Color(0xffffffff)),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Register User",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Provide your details and capture your face for secure account ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Face Data Capture",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Icon(
                    Icons.security_rounded,
                    size: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 270,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://dimg.dreamflow.cloud/v1/image/close%20up%20portrait%20of%20a%20person%20looking%20at%20camera%20neutral%20background"),
                        fit: BoxFit.fill,
                        opacity: 0.6),
                  ),
                  child: Center(
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 2.0, color: const Color(0xFFFFFFFF)),
                          borderRadius: const BorderRadius.all(Radius.circular(40))),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Details(camera: camera)));
                  },
                  style: FilledButton.styleFrom(fixedSize: const Size(200, 40)),
                  child: const Text(
                    "Record Details",
                  ),
                ),
              ),
              Center(
                child: ErrorMessageWidget(
                  errorMessage: "[error]",
                  onDismissed: () {
                    debugPrint("IT is DIsmissied");
                  },
                ),
              )
            ]),
          ),
        ));
  }
}
