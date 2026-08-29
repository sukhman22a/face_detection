import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// server addressssss
//direct ip of computer on the network .. Hostname -I
// final wsURRl = Uri.parse('ws://192.168.0.110:8000/ws/live-feed');
final String kBaseWsUrl = 'ws://192.168.43.96:8000/ws/live-feed';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("IMAGGGE")),
      body: Center(
          child:
              kIsWeb ? Image.network(imagePath) : Image.file(File(imagePath))),
    );
  }
}

class TakePicture extends StatefulWidget {
  final CameraDescription camera;
  final Map<String,String> userInfo;
  final bool isRegister;
  const TakePicture({super.key, required this.camera, required this.userInfo, required this.isRegister});
  @override
  _TakePictureState createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  CameraController? _controller;
  bool isInitialized = false;
  WebSocketChannel? _channel;
  bool _isProcessingFrame = false;
  String _recoginitionResult = "Initializing....";
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeWebSocket();
  }

  void _initializeWebSocket() async {
    final String endpoint = widget.isRegister ? kBaseWsUrl : '$kBaseWsUrl/Login';

    final wsUrl = Uri.parse(endpoint);
    _channel = WebSocketChannel.connect(wsUrl);
    // final Map<String,String> userInfo = {
    //   "type":"init",
    //   "name":name,
    //   "email":email,
    //   "phoneNo":phoneNo
    // };
    if (widget.isRegister){
    _channel!.sink.add(jsonEncode(widget.userInfo));
    }
    _channel!.stream.listen((message) {
      setState(() {
        _recoginitionResult = message.toString();
      });
    }, onError: (error) {
      debugPrint("web socket error : $error");
    }, onDone: () {
      debugPrint("web Socket connection closed");
    });
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.low,
        enableAudio: false);

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          isInitialized = true;
        });
        _startStreaming();
      }
    } catch (e) {
      debugPrint("Camera initiait not done");
    }
  }

  void _startStreaming() {
    _controller?.startImageStream((CameraImage image) async {
      if (_isProcessingFrame) return;
      _isProcessingFrame = true;

      try {
        
        if (_channel != null) {
          // header variables
          final plane = image.planes[0];
          final int width = image.width;
          final int height = image.height;
          final int bytesPerRow = plane.bytesPerRow;
          final Uint8List yBytes = plane.bytes;

          final ByteData header = ByteData(12)
            ..setUint32(0, width, Endian.big)
            ..setUint32(4, height, Endian.big)
            ..setUint32(8, bytesPerRow, Endian.big);

          final Uint8List payload = Uint8List(12 + yBytes.length)
            ..setRange(0, 12, header.buffer.asUint8List())
            ..setRange(12, 12 + yBytes.length, yBytes);
          _channel!.sink.add(payload);
        }
      } catch (e) {
        debugPrint("Error sending frames : $e");
      } finally {
        await Future.delayed(const Duration(milliseconds: 200));
        _isProcessingFrame = false;
      }
    });
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("live Recognition"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
                child: ClipOval(
                    child: SizedBox(
                        height: 300,
                        width: 300,
                        child: CameraPreview(_controller!)))),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _recoginitionResult,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.camera_alt_rounded),
      //   onPressed: () async {
      //     try {
      //       final image = await _controller!.takePicture();
      //       if (!context.mounted) return;
      //       await Navigator.of(context).push(MaterialPageRoute(
      //           builder: (context) =>
      //               DisplayPictureScreen(imagePath: image.path)));
      //     } catch (e) {
      //       print(e);
      //     }
      //   },
      // ),
    );
  }
}
