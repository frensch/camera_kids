import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_kids/MainScaffold.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
      .requestPermissions([PermissionGroup.storage, PermissionGroup.camera]);

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final selfieCamera = cameras.last;

  //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  //   .then((_) {

  ThemeData themeData = new ThemeData(backgroundColor: Colors.grey);
  runApp(
    MaterialApp(
      theme: themeData,
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: selfieCamera,
      ),
    ),
  );
  //});
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
        enableAudio: false
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(cameraController: _controller, initializeControllerFuture: _initializeControllerFuture);
  }
}

// A widget that displays the picture taken by the user.

