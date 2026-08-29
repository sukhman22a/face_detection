import 'package:camera/camera.dart';
import 'package:face_recogination/cammeraa/example.dart';
import 'package:flutter/material.dart';
class Details extends StatefulWidget {
  final CameraDescription camera;
  
  const Details({super.key,required this.camera});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  
  String _name = '';
  String _email = '';
  String _phoneNo = '';

  @override
  Widget build(BuildContext context) {
    final CameraDescription camera = widget.camera;
    return Scaffold(
        appBar: AppBar(
          title: Text("Details"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "enter your name"),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                  print(_name);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "Email"),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "ENTER your phon no"),
                    onChanged: (value) {
                      setState(() {
                        _phoneNo = value;
                      });
                    })
                    ),
          FloatingActionButton(
            onPressed:(){
              _submitForm(camera);
            } )

          ],
        ));
  }
  void _submitForm(CameraDescription camera){
      Map<String,String> userInfo = {
                "name":_name,
                "email":_email,
                "phoneNo":_phoneNo,
              };
      Navigator.push(
                context,
              MaterialPageRoute(builder: (context)=> TakePicture(camera: camera,userInfo: userInfo,isRegister: true,)) );
      
  }

  // Future<void> sendUserData(String name,String email, String phoneNo,String randomNumber) async{
  //   final Uri url = Uri.parse("http://192.168.43.96:8000/Register");
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: <String,String>{
  //         'Content-Type':'application/json; character=UTF-8',
  //       },
  //       body: jsonEncode(<String, String>{
  //       'name': name,
  //       'email': email,
  //       'phoneNo':_phoneNo,
  //       // 'randomNumber':randomNumber
  //     }),
  //     );
  //     if (response.statusCode ==200 || response.statusCode == 201){
  //       final responseData = jsonDecode(response.body);
  //       print("success: ${responseData['message']}");
  //     }
  //     else{
  //       print("failed with status code: ${response.statusCode}");
  //       print("Response: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error : $e");
  //   }
  // }
  
  }

